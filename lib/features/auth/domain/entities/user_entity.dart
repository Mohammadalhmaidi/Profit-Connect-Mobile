import 'package:equatable/equatable.dart';

/// [UserEntity] represents the core user data structure in the domain layer.
/// 
/// It contains essential identity information such as [id], [email], and [fullName].
/// This class is strictly for business logic and is decoupled from any data source formats.
class UserEntity extends Equatable {
  /// The unique identifier for the user.
  final String id;
  
  /// The user's registered email address.
  final String email;
  
  /// The user's full display name.
  final String fullName;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
  });

  @override
  List<Object?> get props => [id, email, fullName];
}
