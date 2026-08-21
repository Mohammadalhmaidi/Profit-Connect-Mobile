import '../../../../api_service.dart';
import '../models/user_model.dart';

/// تسجيل الدخول الاجتماعي عبر Google.
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
    final response = await _apiService.post(
      '/api/oauth/google',
      data: {
        'idToken': idToken,
        'email': email,
        'firstName': firstName ?? '',
        'lastName': lastName ?? '',
        'avatar': avatar ?? '',
      },
    );
    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token != null) {
      await _apiService.saveToken(token);
    }
    final refreshToken = data['refreshToken'] as String?;
    if (refreshToken != null) {
      await _apiService.saveRefreshToken(refreshToken);
    }
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<bool> isGoogleSignInAvailable() async => true;
}
