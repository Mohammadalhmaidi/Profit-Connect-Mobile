import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/constants/app_constants.dart';
import 'core/error/dio_error_handler.dart';
import 'core/network/api_base_url_resolver.dart';
import 'core/network/connectivity_interceptor.dart';
import 'core/network/retry_interceptor.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static String get baseUrl => ApiBaseUrlResolver.current;

  static const int maxRetries = AppConstants.apiMaxRetries;
  static const Duration retryDelay = Duration(
    seconds: AppConstants.apiRetryDelaySeconds,
  );

  ApiService({
    ConnectivityInterceptor? connectivityInterceptor,
    RetryInterceptor? retryInterceptor,
  }) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(
      seconds: AppConstants.apiTimeoutSeconds,
    );
    _dio.options.receiveTimeout = const Duration(
      seconds: AppConstants.apiTimeoutSeconds,
    );
    _dio.options.contentType = 'application/json';

    _dio.interceptors.add(
      connectivityInterceptor ?? ConnectivityInterceptor(InternetConnection()),
    );
    _dio.interceptors.add(retryInterceptor ?? RetryInterceptor());
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final path = error.requestOptions.path;
          final isAuthPath =
              path.contains('/auth/login') ||
              path.contains('/auth/refresh') ||
              path.contains('/auth/logout');
          if (status == 401 && !isAuthPath) {
            final refreshed = await _tryRefreshTokens();
            if (refreshed) {
              final token = await _storage.read(key: 'auth_token');
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (_) {}
            }
          }
          final failure = handleDioError(error);
          final updatedError = error.copyWith(error: failure);
          handler.next(updatedError);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async => _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async => _dio.post(path, data: data, queryParameters: queryParameters);

  Future<Response> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async => _dio.put(path, data: data, queryParameters: queryParameters);

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async => _dio.delete(path, queryParameters: queryParameters);

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
    return _dio.get(path, queryParameters: params);
  }

  // --- Profile ---
  Future<Response> updateProfile(Map<String, dynamic> data) async =>
      _dio.put('/api/user/profile', data: data);

  Future<Response> getProfile() async => _dio.get('/api/user/profile');

  Future<Response> updateAvatar(String avatarPath) async {
    final formData = FormData();
    formData.files.add(
      MapEntry('avatar', await MultipartFile.fromFile(avatarPath)),
    );
    return _dio.put(
      '/api/user/profile/avatar',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async => _dio.put(
    '/api/user/change-password',
    data: {'currentPassword': currentPassword, 'newPassword': newPassword},
  );

  Future<Response> getSettings() async => _dio.get('/api/user/settings');

  Future<Response> updateSettings(Map<String, dynamic> data) async =>
      _dio.put('/api/user/settings', data: data);

  // --- Saved Posts ---
  Future<Response> savePost(String postId) async =>
      _dio.post('/api/user/saved-posts/$postId');

  Future<Response> unsavePost(String postId) async =>
      _dio.delete('/api/user/saved-posts/$postId');

  Future<Response> getSavedPosts() async => _dio.get('/api/user/saved-posts');

  // --- Saved Jobs ---
  Future<Response> saveJob(String jobId) async =>
      _dio.post('/api/user/saved-jobs/$jobId');

  Future<Response> unsaveJob(String jobId) async =>
      _dio.delete('/api/user/saved-jobs/$jobId');

  Future<Response> getSavedJobs() async => _dio.get('/api/user/saved-jobs');

  Future<Response> getTopUsers({int limit = 10, String? role}) async =>
      _dio.get(
        '/api/user/leaderboard/top-users',
        queryParameters: {'limit': limit, if (role != null) 'role': role},
      );

  Future<Response> getTopManagers({int limit = 10}) async => _dio.get(
    '/api/companies/leaderboard/top-managers',
    queryParameters: {'limit': limit},
  );

  // --- Follow (mounted at /api/users) ---
  Future<Response> followUser(String userId) async =>
      _dio.post('/api/users/$userId/follow');

  Future<Response> unfollowUser(String userId) async =>
      _dio.delete('/api/users/$userId/follow');

  Future<Response> getUserById(String userId) async =>
      _dio.get('/api/user/$userId');

  Future<Response> getMyFollowing() async => _dio.get('/api/network/following');

  Future<Response> getUserFollowers(String userId) async =>
      _dio.get('/api/user/$userId/followers');

  Future<Response> getUserFollowing(String userId) async =>
      _dio.get('/api/user/$userId/following');

  // --- Network ---
  Future<Response> searchUsers(String query, {int limit = 20}) async =>
      _dio.get(
        '/api/network/search',
        queryParameters: {'q': query, 'limit': limit},
      );

  Future<Response> getNetworkRequests() async =>
      _dio.get('/api/network/requests');

  Future<Response> getMyConnectionsList() async =>
      _dio.get('/api/network/connections');

  Future<Response> getDiscoverUsers({int limit = 10}) async =>
      _dio.get('/api/network/discover', queryParameters: {'limit': limit});

  Future<Response> getNetworkStats() async => _dio.get('/api/network/stats');

  Future<Response> sendConnectionRequest(String userId) async =>
      _dio.post('/api/network/connect/$userId');

  Future<Response> acceptConnectionRequest(String requestId) async =>
      _dio.put('/api/network/accept/$requestId');

  Future<Response> rejectConnectionRequest(String requestId) async =>
      _dio.put('/api/network/reject/$requestId');

  Future<Response> removeConnection(String userId) async =>
      _dio.delete('/api/network/remove/$userId');

  // --- Company ---
  Future<Response> getCompanyById(String companyId) async =>
      _dio.get('/api/companies/$companyId');

  Future<Response> getCompanyStats(String companyId) async =>
      _dio.get('/api/companies/$companyId/stats');

  Future<Response> getCompanyFollowers(String companyId) async =>
      _dio.get('/api/companies/$companyId/followers');

  Future<Response> toggleFollowCompany(String companyId) async =>
      _dio.post('/api/companies/$companyId/follow');

  Future<Response> addCompanyAdmin(String companyId, String newAdminId) async =>
      _dio.post(
        '/api/companies/$companyId/admins',
        data: {'newAdminId': newAdminId},
      );

  /// Finds the id of a company owned by [userId] (Employer role),
  /// scanning the approved-company directory pages.
  Future<String?> findOwnedCompanyId(String userId, {int maxPages = 5}) async {
    for (var page = 1; page <= maxPages; page++) {
      final res = await _dio.get(
        '/api/companies',
        queryParameters: {'page': page, 'limit': 100},
      );
      final data = res.data['data'] as List<dynamic>? ?? [];
      if (data.isEmpty) break;
      for (final company in data) {
        if (company is Map) {
          final owner = company['owner'];
          if (owner is Map && owner['_id']?.toString() == userId ||
              owner?.toString() == userId) {
            return company['_id']?.toString();
          }
        }
      }
      final total = (res.data['total'] as num?)?.toInt() ?? 0;
      if (page * 100 >= total) break;
    }
    return null;
  }

  // --- Jobs ---
  Future<Response> getMyApplications() async =>
      _dio.get('/api/jobs/my-applications');

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
    return _dio.post(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  // --- Auth ---
  Future<Response> login(String email, String password) async => _dio.post(
    '/api/auth/login',
    data: {'email': email, 'password': password},
  );

  Future<Response> forgotPassword(String email) async =>
      _dio.post('/api/auth/forgot-password', data: {'email': email});

  // --- Portfolio (المعرض) ---
  Future<Response> getMyPortfolioItems({int page = 1, int limit = 12}) async =>
      _dio.get(
        '/api/portfolio/items',
        queryParameters: {'page': page, 'limit': limit},
      );

  Future<Response> getUserPortfolioItems(
    String userId, {
    int page = 1,
    int limit = 12,
  }) async => _dio.get(
    '/api/portfolio/users/$userId/items',
    queryParameters: {'page': page, 'limit': limit},
  );

  Future<Response> getPortfolioItemById(String itemId) async =>
      _dio.get('/api/portfolio/items/$itemId');

  Future<Response> createPortfolioItem({
    required String title,
    required String category,
    String description = '',
    List<String> tags = const [],
    List<String> skills = const [],
    String client = '',
    String duration = '',
    String role = '',
    String projectUrl = '',
    String visibility = 'public',
    String? linkedProject,
    List<MultipartFile>? media,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('title', title));
    formData.fields.add(MapEntry('category', category));
    formData.fields.add(MapEntry('description', description));
    if (tags.isNotEmpty) {
      formData.fields.add(MapEntry('tags', jsonEncode(tags)));
    }
    if (skills.isNotEmpty) {
      formData.fields.add(MapEntry('skills', jsonEncode(skills)));
    }
    if (client.isNotEmpty) formData.fields.add(MapEntry('client', client));
    if (duration.isNotEmpty) {
      formData.fields.add(MapEntry('duration', duration));
    }
    if (role.isNotEmpty) formData.fields.add(MapEntry('role', role));
    if (projectUrl.isNotEmpty) {
      formData.fields.add(MapEntry('projectUrl', projectUrl));
    }
    if (linkedProject != null && linkedProject.isNotEmpty) {
      formData.fields.add(MapEntry('linkedProject', linkedProject));
    }
    formData.fields.add(MapEntry('visibility', visibility));
    for (final file in media ?? const <MultipartFile>[]) {
      formData.files.add(MapEntry('media', file));
    }
    return _dio.post(
      '/api/portfolio/items',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<Response> deletePortfolioItem(String itemId) async =>
      _dio.delete('/api/portfolio/items/$itemId');

  Future<Response> togglePortfolioLike(String itemId) async =>
      _dio.post('/api/portfolio/items/$itemId/like');

  Future<Response> getMyPortfolioCollections() async =>
      _dio.get('/api/portfolio/collections');

  Future<Response> createPortfolioCollection({
    required String name,
    String description = '',
    bool isPublic = true,
  }) async => _dio.post(
    '/api/portfolio/collections',
    data: {'name': name, 'description': description, 'isPublic': isPublic},
  );

  Future<Response> deletePortfolioCollection(String collectionId) async =>
      _dio.delete('/api/portfolio/collections/$collectionId');

  Future<Response> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async => _dio.post(
    '/api/auth/reset-password',
    data: {'email': email, 'code': code, 'password': newPassword},
  );

  // --- Posts ---
  Future<Response> getPosts({
    int page = 1,
    int limit = 10,
    String? cursor,
    String? hashtag,
  }) async => getPaginated(
    '/api/posts',
    page: page,
    limit: limit,
    cursor: cursor,
    extraParams: {if (hashtag != null && hashtag.isNotEmpty) 'hashtag': hashtag},
  );

  Future<Response> getPostById(String postId) async =>
      _dio.get('/api/posts/$postId');

  Future<Response> createPost(Map<String, dynamic> data) async =>
      _dio.post('/api/posts', data: data);

  Future<Response> createPostMultipart(
    Map<String, dynamic> data, {
    String? imagePath,
    String? videoPath,
  }) async {
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
    if (imagePath != null && imagePath.isNotEmpty) {
      formData.files.add(
        MapEntry('image', await MultipartFile.fromFile(imagePath)),
      );
    }
    if (videoPath != null && videoPath.isNotEmpty) {
      formData.files.add(
        MapEntry('video', await MultipartFile.fromFile(videoPath)),
      );
    }
    return _dio.post(
      '/api/posts',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<Response> likePost(String postId) async =>
      _dio.post('/api/posts/$postId/like');

  Future<Response> sharePost(String postId) async =>
      _dio.post('/api/posts/$postId/share');

  Future<Response> addComment(String postId, String comment) async =>
      _dio.post('/api/posts/$postId/comments', data: {'content': comment});

  Future<Response> likeComment(String postId, String commentId) async =>
      _dio.post('/api/posts/$postId/comments/$commentId/like');

  // --- Notifications ---
  Future<Response> getNotifications() async =>
      _dio.get('/api/projects/notifications');

  Future<Response> markAllNotificationsRead() async =>
      _dio.put('/api/projects/notifications/read-all');

  // --- Companies ---
  Future<Response> getCompanies({Map<String, dynamic>? params}) async =>
      _dio.get('/api/companies', queryParameters: params);

  Future<Response> createCompany(Map<String, dynamic> data) async =>
      _dio.post('/api/companies', data: data);

  Future<Response> rateCompany(
    String companyId,
    int rating, {
    String? review,
  }) async => _dio.post(
    '/api/companies/$companyId/ratings',
    data: {'rating': rating, if (review != null) 'review': review},
  );

  // --- Jobs ---
  Future<Response> getJobs({
    String? search,
    String? type,
    String? workPlace,
    String? workLevel,
    int page = 1,
    int limit = 20,
    String? cursor,
  }) async => getPaginated(
    '/api/jobs',
    page: page,
    limit: limit,
    cursor: cursor,
    extraParams: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (type != null) 'type': type,
      if (workPlace != null) 'workPlace': workPlace,
      if (workLevel != null) 'workLevel': workLevel,
    },
  );

  Future<Response> getJobById(String jobId) async =>
      _dio.get('/api/jobs/$jobId');

  Future<Response> applyJob(
    String jobId, {
    String? resumePath,
    String? resumeLink,
    String? coverLetter,
  }) async {
    if (resumePath != null) {
      final file = await MultipartFile.fromFile(resumePath);
      return postMultipart(
        '/api/jobs/$jobId/apply',
        data: {if (coverLetter != null) 'coverLetter': coverLetter},
        files: {'resume': file},
      );
    }
    return _dio.post(
      '/api/jobs/$jobId/apply',
      data: {
        if (resumeLink != null) 'resumeLink': resumeLink,
        if (coverLetter != null) 'coverLetter': coverLetter,
      },
    );
  }

  // --- Messages (REST) ---
  Future<Response> getOrCreateConversation(String recipientId) async => _dio
      .post('/api/messages/conversations', data: {'recipientId': recipientId});

  Future<Response> getConversations({
    int page = 1,
    int limit = 20,
    String? q,
  }) async => _dio.get(
    '/api/messages/conversations',
    queryParameters: {
      'page': page,
      'limit': limit,
      if (q != null && q.isNotEmpty) 'q': q,
    },
  );

  Future<Response> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async => _dio.get(
    '/api/messages/conversations/$conversationId',
    queryParameters: {'page': page, 'limit': limit},
  );

  Future<Response> sendMessage(String conversationId, String content) async =>
      _dio.post(
        '/api/messages/conversations/$conversationId',
        data: {'content': content},
      );

  Future<Response> startConversation(String recipientId) async => _dio.post(
    '/api/messages/conversations',
    data: {'recipientId': recipientId},
  );

  // --- Projects ---
  Future<Response> getProjects({Map<String, dynamic>? params}) async =>
      _dio.get('/api/projects', queryParameters: params);

  Future<Response> createProject(Map<String, dynamic> data) async =>
      _dio.post('/api/projects', data: data);

  // --- Translate ---
  Future<Response> translate(String text) async =>
      _dio.post('/api/translate', data: {'text': text});

  // --- Improve ---
  Future<Response> improve(String text) async =>
      _dio.post('/api/improve', data: {'text': text});

  // --- Wallet ---
  Future<Response> getWallet() async => _dio.get('/api/wallet');

  Future<Response> requestWithdrawal({
    required num amount,
    String method = 'bank_transfer',
    Map<String, dynamic>? accountDetails,
  }) => _dio.post(
    '/api/wallet/withdraw',
    data: {
      'amount': amount,
      'method': method,
      'accountDetails': accountDetails ?? {},
    },
  );

  Future<Response> getMyWithdrawals() async =>
      _dio.get('/api/wallet/withdrawals');

  Future<Response> cancelWithdrawal(String withdrawalId) async =>
      _dio.post('/api/wallet/withdrawals/$withdrawalId/cancel');

  // --- Payments ---
  Future<Response> getMyPayments({String? direction, String? status}) async =>
      _dio.get(
        '/api/payments',
        queryParameters: {
          if (direction != null) 'direction': direction,
          if (status != null) 'status': status,
        },
      );

  Future<Response> releasePayment(String paymentId) async =>
      _dio.put('/api/payments/$paymentId/release');

  // --- Salaries ---
  Future<Response> getSalaryOptions() async =>
      _dio.get('/api/salaries/options');

  Future<Response> getSalaryStats({
    String? title,
    String? country,
    String? experienceLevel,
  }) async => _dio.get(
    '/api/salaries/stats',
    queryParameters: {
      if (title != null) 'title': title,
      if (country != null) 'country': country,
      if (experienceLevel != null) 'experienceLevel': experienceLevel,
    },
  );

  Future<Response> getSalaries({
    String? title,
    String? country,
    String? experienceLevel,
    String? category,
    int page = 1,
    int limit = 20,
  }) => _dio.get(
    '/api/salaries',
    queryParameters: {
      if (title != null) 'title': title,
      if (country != null) 'country': country,
      if (experienceLevel != null) 'experienceLevel': experienceLevel,
      if (category != null) 'category': category,
      'page': page,
      'limit': limit,
    },
  );

  // --- Employee / Company management ---
  Future<Response> getMyCompany({String? companyId}) async => _dio.get(
    '/api/employee/my-company',
    queryParameters: {if (companyId != null) 'companyId': companyId},
  );

  Future<Response> getCompanyEmployees(String companyId) async =>
      _dio.get('/api/companies/$companyId/employees');

  Future<Response> addEmployee(
    String companyId,
    Map<String, dynamic> data,
  ) async => _dio.post('/api/companies/$companyId/employees', data: data);

  Future<Response> removeEmployee(String companyId, String employeeId) async =>
      _dio.delete('/api/companies/$companyId/employees/$employeeId');

  Future<Response> updateEmployee(
    String companyId,
    String employeeId,
    Map<String, dynamic> data,
  ) async =>
      _dio.put('/api/companies/$companyId/employees/$employeeId', data: data);

  Future<Response> getCompanyJobs({String? companyId}) async => _dio.get(
    '/api/employee/jobs',
    queryParameters: {if (companyId != null) 'companyId': companyId},
  );

  Future<Response> createCompanyJob(
    Map<String, dynamic> data, {
    String? companyId,
  }) async => _dio.post(
    '/api/employee/jobs',
    data: {...data, if (companyId != null) 'companyId': companyId},
  );

  Future<Response> getJobApplicants(String jobId) async =>
      _dio.get('/api/employee/jobs/$jobId/applicants');

  Future<Response> updateApplicationStatus(
    String applicationId,
    String status,
  ) async => _dio.put(
    '/api/employee/jobs/applications/$applicationId/status',
    data: {'status': status},
  );

  // --- Projects ---
  Future<Response> getMyProjectsWithProposals() async =>
      _dio.get('/api/projects/my-projects-with-proposals');

  Future<Response> getMyProposals() async =>
      _dio.get('/api/projects/my-proposals');

  Future<Response> getProjectOverview(String projectId) async =>
      _dio.get('/api/projects/$projectId/overview');

  // --- Token management ---
  Future<void> saveToken(String token) async =>
      _storage.write(key: 'auth_token', value: token);

  Future<String?> getToken() async => _storage.read(key: 'auth_token');

  Future<void> saveRefreshToken(String token) async =>
      _storage.write(key: 'auth_refresh_token', value: token);

  Future<String?> getRefreshToken() async =>
      _storage.read(key: 'auth_refresh_token');

  Future<bool>? _refreshingFuture;

  /// ينسّق طلبات التحديث المتزامنة: أي 401 أثناء تحديث جارٍ ينتظر نفس المستقبل
  /// بدلاً من إرسال طلب refresh آخر. عند فشل التحديث تُمسح التوكنات فوراً.
  Future<bool> _tryRefreshTokens() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    if (_refreshingFuture != null) return _refreshingFuture!;
    final future = _doRefresh(refreshToken);
    _refreshingFuture = future;
    try {
      return await future;
    } finally {
      _refreshingFuture = null;
    }
  }

  Future<bool> _doRefresh(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final body = response.data;
      final map = body is Map
          ? Map<String, dynamic>.from(body)
          : const <String, dynamic>{};
      final token = map['token'];
      final newRefreshToken = map['refreshToken'];
      if (token != null) {
        await saveToken(token);
        if (newRefreshToken != null) {
          await saveRefreshToken(newRefreshToken);
        }
        return true;
      }
      await _clearTokens();
      return false;
    } catch (_) {
      await _clearTokens();
      return false;
    }
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'auth_refresh_token');
  }

  Future<void> logout() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _dio.post(
          '/api/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      } catch (_) {}
    }
    await _clearTokens();
  }

  Future<bool> hasToken() async =>
      (await _storage.read(key: 'auth_token')) != null;

  Future<String?> getCurrentUserId() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload);
      if (json is! Map) return null;
      return json['id']?.toString();
    } catch (_) {
      return null;
    }
  }
}
