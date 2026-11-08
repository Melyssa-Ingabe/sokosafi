part of 'auth_bloc.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

/// A one-time message for the UI to show in a SnackBar. It is deliberately
/// not Equatable: every new instance counts as a new message, so the same
/// error twice in a row still reaches a BlocListener.
class AuthFeedback {
  AuthFeedback.error(this.message) : isError = true;
  AuthFeedback.success(this.message) : isError = false;

  final String message;
  final bool isError;
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.feedback,
  });

  final AuthStatus status;
  final AppUser? user;
  final bool isLoading;
  final AuthFeedback? feedback;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool clearUser = false,
    bool? isLoading,
    AuthFeedback? feedback,
    bool clearFeedback = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
    );
  }

  @override
  List<Object?> get props => [status, user, isLoading, feedback];
}
