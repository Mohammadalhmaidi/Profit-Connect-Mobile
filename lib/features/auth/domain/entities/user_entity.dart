import 'package:equatable/equatable.dart';

enum UserRole { Employer, JobSeeker, Admin, FreelanceClient }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String firstName;
  final String lastName;
  final UserRole role;
  final List<String> skills;
  final String? companyId;
  final String? avatar;
  final String? headline;
  final String? bio;
  final String? industry;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.firstName = '',
    this.lastName = '',
    this.role = UserRole.JobSeeker,
    this.skills = const [],
    this.companyId,
    this.avatar,
    this.headline,
    this.bio,
    this.industry,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? firstName,
    String? lastName,
    UserRole? role,
    List<String>? skills,
    String? companyId,
    String? avatar,
    String? headline,
    String? bio,
    String? industry,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      skills: skills ?? this.skills,
      companyId: companyId ?? this.companyId,
      avatar: avatar ?? this.avatar,
      headline: headline ?? this.headline,
      bio: bio ?? this.bio,
      industry: industry ?? this.industry,
    );
  }

  @override
  List<Object?> get props => [
        id, email, fullName, firstName, lastName, role,
        skills, companyId, avatar, headline, bio, industry,
      ];
}
