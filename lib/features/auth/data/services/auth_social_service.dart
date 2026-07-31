import 'package:flutter/foundation.dart';
import '../../../../api_service.dart';
import '../models/user_model.dart';

class AuthSocialService {
  final ApiService _apiService;

  AuthSocialService(this._apiService);

  Future<UserModel> signInWithGoogle({
    required String idToken,
    required String email,
    String? firstName,
    String? lastName,
    String? avatar,
  }) async {
    final response = await _apiService.post('/api/oauth/google', data: {
      'idToken': idToken,
      'email': email,
      'firstName': firstName ?? '',
      'lastName': lastName ?? '',
      'avatar': avatar ?? '',
    });
    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token != null) {
      await _apiService.saveToken(token);
    }
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> signInWithLinkedIn({
    required String accessToken,
    required String email,
    String? firstName,
    String? lastName,
    String? avatar,
    String? headline,
  }) async {
    final response = await _apiService.post('/api/oauth/linkedin', data: {
      'accessToken': accessToken,
      'email': email,
      'firstName': firstName ?? '',
      'lastName': lastName ?? '',
      'avatar': avatar ?? '',
      'headline': headline ?? '',
    });
    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token != null) {
      await _apiService.saveToken(token);
    }
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<bool> isGoogleSignInAvailable() async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }
}