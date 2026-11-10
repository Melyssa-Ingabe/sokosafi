part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Starts listening to the signed-in user. Sent once when the app launches.
final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthEmailLoginRequested extends AuthEvent {
  const AuthEmailLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  final String name;
  final String email;
  final String phone;
  final String password;

  @override
  List<Object?> get props => [name, email, phone, password];
}

final class AuthGoogleLoginRequested extends AuthEvent {
  const AuthGoogleLoginRequested();
}

final class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

final class AuthVerificationEmailResendRequested extends AuthEvent {
  const AuthVerificationEmailResendRequested();
}

final class AuthVerificationChecked extends AuthEvent {
  const AuthVerificationChecked();
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
