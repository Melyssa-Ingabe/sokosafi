/// Throws a ProfileFailure with a readable message on error.
abstract interface class ProfileRepository {
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
  });
}
