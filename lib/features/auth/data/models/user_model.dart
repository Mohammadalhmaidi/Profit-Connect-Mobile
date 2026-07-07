import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String role;
  final String firstName;
  final String lastName;

  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required this.role,
    required this.firstName,
    required this.lastName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handling both backend structures (_id or id)
    return UserModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      fullName: json['fullName'] ?? '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'role': role,
    };
  }
}
