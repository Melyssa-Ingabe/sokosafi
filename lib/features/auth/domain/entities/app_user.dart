import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/auth/domain/entities/user_role.dart';

/// The signed-in user: Firebase Auth identity plus the users/{uid} profile.
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.photoUrl,
    required this.foodPreferences,
    required this.isEmailVerified,
  });

  final String uid;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final String photoUrl;
  final List<String> foodPreferences;
  final bool isEmailVerified;

  @override
  List<Object?> get props => [
    uid,
    email,
    name,
    phone,
    role,
    photoUrl,
    foodPreferences,
    isEmailVerified,
  ];
}
