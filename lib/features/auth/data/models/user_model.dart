import '../../../../core/utils/media_url_helper.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.firstName,
    super.lastName,
    super.role,
    super.skills,
    super.companyId,
    super.avatar,
    super.headline,
    super.bio,
    super.industry,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>?;
    final professional = json['professional'] as Map<String, dynamic>?;
    final employerProfile = json['employerProfile'] as Map<String, dynamic>?;

    final firstName = profile?['firstName'] as String? ?? json['firstName'] ?? '';
    final lastName = profile?['lastName'] as String? ?? json['lastName'] ?? '';
    final roleStr = json['role'] as String? ?? 'JobSeeker';

    return UserModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      email: json['email'] ?? '',
      fullName: profile?['fullname'] as String? ??
          json['fullName'] as String? ??
          '$firstName $lastName'.trim(),
      firstName: firstName,
      lastName: lastName,
      role: UserRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => UserRole.JobSeeker,
      ),
      skills: (professional?['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      companyId: json['companyId']?.toString(),
      avatar: MediaUrlHelper.resolve(profile?['avatar'] as String? ?? json['avatar'] as String?),
      headline: profile?['headline'] as String? ?? json['headline'] as String?,
      bio: profile?['bio'] as String? ?? json['bio'] as String?,
      industry: professional?['industry'] as String? ??
          employerProfile?['industry'] as String? ??
          json['industry'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.name,
      'skills': skills,
      'companyId': companyId,
      'avatar': avatar,
      'headline': headline,
      'bio': bio,
      'industry': industry,
    };
  }
}
