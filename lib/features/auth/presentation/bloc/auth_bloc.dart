import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/services/auth_social_service.dart';
import '../../../../core/error/failures.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final AuthRepository authRepository;
  final AuthSocialService authSocialService;

  AuthBloc({
    required this.loginUseCase,
    required this.authRepository,
    required this.authSocialService,
  }) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignupSubmitted>(_onSignupSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<LinkedInSignInRequested>(_onLinkedInSignIn);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    if (event.forceFetch) {
      final result = await authRepository.getCurrentUser();
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    } else {
      final isLoggedIn = await authRepository.isUserLoggedIn();
      if (isLoggedIn) {
        final result = await authRepository.getCurrentUser();
        result.fold(
          (failure) {
            if (failure is UnauthorizedFailure) {
              authRepository.logout();
              emit(AuthInitial());
            } else {
              emit(AuthFailure(failure.message));
            }
          },
          (user) => emit(AuthSuccess(user)),
        );
      } else {
        emit(AuthInitial());
      }
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthLoading) return;
    emit(AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthFailure(
        failure.message,
        statusCode: failure.statusCode,
      )),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.signup(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      password: event.password,
      role: event.role,
      skills: event.skills,
    );

    result.fold(
      (failure) => emit(AuthFailure(
        failure.message,
        statusCode: failure.statusCode,
      )),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(AuthInitial());
  }

  Future<void> _onGoogleSignIn(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authSocialService.signInWithGoogle(
        idToken: event.idToken,
        email: event.email,
        firstName: event.firstName,
        lastName: event.lastName,
        avatar: event.avatar,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLinkedInSignIn(
    LinkedInSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authSocialService.signInWithLinkedIn(
        accessToken: event.accessToken,
        email: event.email,
        firstName: event.firstName,
        lastName: event.lastName,
        avatar: event.avatar,
        headline: event.headline,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
