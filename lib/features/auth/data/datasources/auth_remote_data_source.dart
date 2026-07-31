import '../../../../api_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    List<String> skills = const [],
    String? phoneNumber,
    String? industry,
    String? companyName,
    String? companyDescription,
    String? companyIndustry,
    String? companyLocation,
  });

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSourceImpl(this._apiService);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data;
    final map = data is Map ? Map<String, dynamic>.from(data) : const <String, dynamic>{};

    final String? token = map['token'];
    if (token != null) {
      await _apiService.saveToken(token);
    }

    final userJson = map['user'];
    if (userJson is! Map) {
      throw const FormatException('Missing user data in login response');
    }
    return UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }

  @override
  Future<UserModel> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    List<String> skills = const [],
    String? phoneNumber,
    String? industry,
    String? companyName,
    String? companyDescription,
    String? companyIndustry,
    String? companyLocation,
  }) async {
    // Backend expects multipart/form-data
    final formData = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'role': role,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (industry != null) 'industry': industry,
      if (companyName != null) 'companyName': companyName,
      if (companyDescription != null) 'companyDescription': companyDescription,
      if (companyIndustry != null) 'companyIndustry': companyIndustry,
      if (companyLocation != null) 'companyLocation': companyLocation,
    };

    final response = await _apiService.postMultipart(
      '/api/auth/signup',
      data: formData,
      files: {
        // if (avatar != null) 'avatar': MultipartFile.fromBytes(...)
      },
      listFields: skills.isNotEmpty ? {'skills': skills} : null,
    );
    final responseData = response.data;
    final map = responseData is Map
        ? Map<String, dynamic>.from(responseData)
        : const <String, dynamic>{};

    final String? token = map['token'];
    if (token != null) {
      await _apiService.saveToken(token);
    }

    final userJson = map['user'];
    if (userJson is! Map) {
      throw const FormatException('Missing user data in signup response');
    }
    return UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _apiService.get('/api/auth/me');
    final data = response.data;
    final map = data is Map ? Map<String, dynamic>.from(data) : const <String, dynamic>{};
    final userJson = map['user'];
    if (userJson is! Map) {
      throw const FormatException('Missing user data in /me response');
    }
    return UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }
}
