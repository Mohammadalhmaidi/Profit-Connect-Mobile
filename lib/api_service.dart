import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/error/dio_error_handler.dart';
import 'core/network/connectivity_interceptor.dart';
import 'core/network/retry_interceptor.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5000';

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  ApiService({
    ConnectivityInterceptor? connectivityInterceptor,
    RetryInterceptor? retryInterceptor,
  }) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.contentType = 'application/json';

    _dio.interceptors.add(connectivityInterceptor ?? ConnectivityInterceptor(InternetConnection()));
    _dio.interceptors.add(retryInterceptor ?? RetryInterceptor(
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final token = await _storage.read(key: 'auth_token');
            if (token != null) {
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
            }
            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (_) {
              return handler.next(error);
            }
          }
        }
        final failure = handleDioError(error);
        error = error.copyWith(error: failure);
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;
      final refreshDio = Dio();
      refreshDio.options.baseUrl = baseUrl;
      refreshDio.options.connectTimeout = const Duration(seconds: 10);
      refreshDio.options.receiveTimeout = const Duration(seconds: 10);
      final response = await refreshDio.post('/api/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      final newToken = response.data['token'] as String?;
      if (newToken != null) {
        await _storage.write(key: 'auth_token', value: newToken);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(path, queryParameters: queryParameters);
  }

  // --- Paginated Requests ---

  Future<Response> getPaginated(
    String path, {
    int page = 1,
    int limit = 20,
    String? cursor,
    Map<String, dynamic>? extraParams,
  }) async {
    final params = <String, dynamic>{
      if (cursor != null) 'cursor': cursor,
      if (page > 1 && cursor == null) 'page': page,
      'limit': limit,
    };
    if (extraParams != null) params.addAll(extraParams);
    return await _dio.get(path, queryParameters: params);
  }

  // --- Profile ---
  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _dio.put('/api/user/profile', data: data);
  }

  // --- Multipart ---
  Future<Response> postMultipart(
    String path, {
    Map<String, dynamic>? data,
    Map<String, MultipartFile>? files,
    Map<String, List<String>>? listFields,
  }) async {
    final formData = FormData();
    if (data != null) {
      data.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });
    }
    if (files != null) {
      files.forEach((key, file) {
        formData.files.add(MapEntry(key, file));
      });
    }
    if (listFields != null) {
      listFields.forEach((key, values) {
        for (final value in values) {
          formData.fields.add(MapEntry(key, value));
        }
      });
    }
    return await _dio.post(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  // --- Auth ---
  Future<Response> login(String email, String password) async {
    return await _dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> refreshToken(String refreshToken) async {
    return await _dio.post('/api/auth/refresh', data: {
      'refreshToken': refreshToken,
    });
  }

  Future<Response> forgotPassword(String email) async {
    return await _dio.post('/api/auth/forgot-password', data: {
      'email': email,
    });
  }

  Future<Response> resetPassword(String email, String code, String newPassword) async {
    return await _dio.post('/api/auth/reset-password', data: {
      'email': email,
      'code': code,
      'password': newPassword,
    });
  }

  // --- Posts ---
  Future<Response> getPosts({int page = 1, int limit = 10, String? cursor}) async {
    return await getPaginated('/api/posts', page: page, limit: limit, cursor: cursor);
  }

  Future<Response> getPostById(String postId) async {
    return await _dio.get('/api/posts/$postId');
  }

  Future<Response> createPost(Map<String, dynamic> data) async {
    return await _dio.post('/api/posts', data: data);
  }

  Future<Response> createPostMultipart(Map<String, dynamic> data) async {
    final formData = FormData();
    data.forEach((key, value) {
      if (value != null) {
        if (value is List) {
          for (final v in value) {
            formData.fields.add(MapEntry(key, v.toString()));
          }
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      }
    });
    return await _dio.post(
      '/api/posts',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<Response> likePost(String postId) async {
    return await _dio.post('/api/posts/$postId/like');
  }

  Future<Response> addComment(String postId, String comment) async {
    return await _dio.post('/api/posts/$postId/comments', data: {
      'content': comment,
    });
  }

  // --- Companies ---
  Future<Response> getCompanies({Map<String, dynamic>? params}) async {
    return await _dio.get('/api/companies', queryParameters: params);
  }

  Future<Response> createCompany(Map<String, dynamic> data) async {
    return await _dio.post('/api/companies', data: data);
  }

  Future<Response> rateCompany(String companyId, int rating, {String? review}) async {
    return await _dio.post('/api/companies/$companyId/ratings', data: {
      'rating': rating,
      if (review != null) 'review': review,
    });
  }

  // --- Jobs ---
  Future<Response> getJobs({
    String? search,
    String? type,
    String? workPlace,
    String? workLevel,
    int page = 1,
    int limit = 20,
    String? cursor,
  }) async {
    return await getPaginated('/api/jobs', page: page, limit: limit, cursor: cursor, extraParams: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (type != null) 'type': type,
      if (workPlace != null) 'workPlace': workPlace,
      if (workLevel != null) 'workLevel': workLevel,
    });
  }

  Future<Response> applyJob(String jobId, {String? resumeLink, String? coverLetter}) async {
    return await _dio.post('/api/jobs/$jobId/apply', data: {
      if (resumeLink != null) 'resumeLink': resumeLink,
      if (coverLetter != null) 'coverLetter': coverLetter,
    });
  }

  // --- Messages (REST) ---
  Future<Response> getOrCreateConversation(String recipientId) async {
    return await _dio.post('/api/messages/conversations', data: {
      'recipientId': recipientId,
    });
  }

  Future<Response> getConversations({int page = 1, int limit = 20}) async {
    return await _dio.get('/api/messages/conversations', queryParameters: {
      'page': page,
      'limit': limit,
    });
  }

  Future<Response> getMessages(String conversationId, {int page = 1, int limit = 50}) async {
    return await _dio.get(
      '/api/messages/conversations/$conversationId',
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<Response> sendMessage(String conversationId, String content) async {
    return await _dio.post(
      '/api/messages/conversations/$conversationId',
      data: {'content': content},
    );
  }

  Future<Response> startConversation(String recipientId) async {
    return await _dio.post('/api/messages/conversations', data: {
      'recipientId': recipientId,
    });
  }

  // --- Projects ---
  Future<Response> getProjects({Map<String, dynamic>? params}) async {
    return await _dio.get('/api/projects', queryParameters: params);
  }

  Future<Response> createProject(Map<String, dynamic> data) async {
    return await _dio.post('/api/projects', data: data);
  }

  // --- Translate ---
  Future<Response> translate(String text) async {
    return await _dio.post('/api/translate', data: {'text': text});
  }

  // --- Token management ---
  Future<void> saveToken(String token) async =>
      await _storage.write(key: 'auth_token', value: token);

  Future<void> saveRefreshToken(String token) async =>
      await _storage.write(key: 'refresh_token', value: token);

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<bool> hasToken() async =>
      (await _storage.read(key: 'auth_token')) != null;

  Future<String?> getCurrentUserId() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final json = jsonDecode(payload);
      if (json is! Map) return null;
      return (json as Map)['id']?.toString();
    } catch (_) {
      return null;
    }
  }
}
