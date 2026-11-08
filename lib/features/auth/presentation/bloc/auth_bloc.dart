import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/auth/domain/entities/app_user.dart';
import 'package:sokosafi/features/auth/domain/failures/auth_failure.dart';
import 'package:sokosafi/features/auth/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this._authRepository}) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthEmailLoginRequested>(_onEmailLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthGoogleLoginRequested>(_onGoogleLoginRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthVerificationEmailResendRequested>(_onVerificationEmailResend);
    on<AuthVerificationChecked>(_onVerificationChecked);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;

  /// Session state comes from the repository stream, so a restart, a role
  /// change or a logout all update the app without extra events.
  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    return emit.forEach<AppUser?>(
      _authRepository.watchUser(),
      onData: (user) => user == null
          ? state.copyWith(status: AuthStatus.unauthenticated, clearUser: true)
          : state.copyWith(status: AuthStatus.authenticated, user: user),
      onError: (error, stackTrace) => state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        feedback: AuthFeedback.error(AuthFailure.genericMessage),
      ),
    );
  }

  Future<void> _onEmailLoginRequested(
    AuthEmailLoginRequested event,
    Emitter<AuthState> emit,
  ) {
    return _runAction(emit, () async {
      await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      return null;
    });
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) {
    return _runAction(emit, () async {
      await _authRepository.register(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
      );
      return null;
    });
  }

  Future<void> _onGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) {
    return _runAction(emit, () async {
      await _authRepository.signInWithGoogle();
      return null;
    });
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) {
    return _runAction(emit, () async {
      await _authRepository.sendPasswordReset(event.email);
      return AuthFeedback.success(
        'If an account exists for that email, a reset link is on its way',
      );
    });
  }

  Future<void> _onVerificationEmailResend(
    AuthVerificationEmailResendRequested event,
    Emitter<AuthState> emit,
  ) {
    return _runAction(emit, () async {
      await _authRepository.resendVerificationEmail();
      return AuthFeedback.success('Verification email sent. Check your inbox');
    });
  }

  Future<void> _onVerificationChecked(
    AuthVerificationChecked event,
    Emitter<AuthState> emit,
  ) {
    return _runAction(emit, () async {
      final isVerified = await _authRepository.reloadUser();
      if (isVerified) return null;
      return AuthFeedback.error(
        'Your email is not verified yet. Open the link we sent you, then try again',
      );
    });
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    return _runAction(emit, () async {
      await _authRepository.signOut();
      return null;
    });
  }

  /// Shows the loading state, runs the action, then clears loading. The action
  /// may return a message to show; known failures become polite error messages.
  Future<void> _runAction(
    Emitter<AuthState> emit,
    Future<AuthFeedback?> Function() action,
  ) async {
    emit(state.copyWith(isLoading: true, clearFeedback: true));
    try {
      final feedback = await action();
      emit(
        state.copyWith(
          isLoading: false,
          feedback: feedback,
          clearFeedback: feedback == null,
        ),
      );
    } on AuthFailure catch (failure) {
      emit(
        state.copyWith(
          isLoading: false,
          feedback: AuthFeedback.error(failure.message),
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          isLoading: false,
          feedback: AuthFeedback.error(AuthFailure.genericMessage),
        ),
      );
    }
  }
}
