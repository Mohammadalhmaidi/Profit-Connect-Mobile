import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'core/api/api_endpoints.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // الرابط الصحيح للأجهزة الحقيقية مع adb reverse
  final String baseUrl = "http://127.0.0.1:5000";

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.contentType = 'application/json';
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // --- دالة فحص الاتصال (مطلوبة في main.dart) ---
  Future<void> fetchMessage() async {
    try {
      final response = await _dio.get('/');
      debugPrint('✅ Backend Online: ${response.data}');
    } catch (e) {
      debugPrint('⚠️ Backend Health Check Failed: $e');
    }
  }

  // --- دوال المصادقة (مطلوبة في auth_remote_data_source.dart) ---
  Future<Response> login(String email, String password) async {
    return await _dio.post(ApiEndpoints.login, data: {
      'email': email,
      'password': password,
    });
  }

  // --- دوال الوظائف ---
  Future<Response> getJobs({String? type, String? workPlace}) async {
    return await _dio.get(ApiEndpoints.jobs, queryParameters: {
      if (type != null) 'type': type,
      if (workPlace != null) 'workPlace': workPlace,
    });
  }

  // --- دوال المنشورات ---
  Future<Response> getPosts() async {
    return await _dio.get(ApiEndpoints.posts);
  }

  // الدوال المساعدة لإدارة التوكين
  Future<void> saveToken(String token) async => await _storage.write(key: 'auth_token', value: token);
  Future<void> logout() async => await _storage.delete(key: 'auth_token');
  Future<bool> hasToken() async => (await _storage.read(key: 'auth_token')) != null;
}
