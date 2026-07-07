import '../../../../api_service.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSourceImpl(this._apiService);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.login(email, password);

      if (response.data != null && response.data['user'] != null) {
        // --- حفظ الـ Token تلقائياً عند النجاح ---
        final String? token = response.data['token'];
        if (token != null) {
          await _apiService.saveToken(token);
        }

        return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
      } else {
        throw Exception('Login failed: User data not found.');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Connection error';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
