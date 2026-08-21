part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {
  final bool forceFetch;
  const CheckAuthStatus({this.forceFetch = false});

  @override
  List<Object?> get props => [forceFetch];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignupSubmitted extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role;
  final List<String> skills;
  final String? avatarPath;
  final String? gender;

  const SignupSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
    this.skills = const [],
    this.avatarPath,
    this.gender,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    password,
    role,
    skills,
    avatarPath,
    gender,
  ];
}

class LogoutRequested extends AuthEvent {}

class GoogleSignInRequested extends AuthEvent {
  final String idToken;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatar;

  const GoogleSignInRequested({
    required this.idToken,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatar,
  });

  @override
  List<Object?> get props => [idToken, email, firstName, lastName, avatar];
}
