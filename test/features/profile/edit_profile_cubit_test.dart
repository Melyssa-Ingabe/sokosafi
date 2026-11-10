import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/profile/data/repositories/firestore_profile_repository.dart';
import 'package:sokosafi/features/profile/domain/failures/profile_failure.dart';
import 'package:sokosafi/features/profile/domain/repositories/profile_repository.dart';
import 'package:sokosafi/features/profile/presentation/cubit/edit_profile_cubit.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  test(
    'saving writes the trimmed name and phone to the user document',
    () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('prince').set({
        'name': 'Old name',
        'phone': '',
        'email': 'prince@example.com',
      });
      final cubit = EditProfileCubit(
        repository: FirestoreProfileRepository(firestore: firestore),
        uid: 'prince',
      );

      await cubit.save(name: '  Prince Mukunzi ', phone: '0788412890');

      final saved = await firestore.collection('users').doc('prince').get();
      expect(saved.data(), containsPair('name', 'Prince Mukunzi'));
      expect(saved.data(), containsPair('phone', '0788412890'));
      expect(saved.data(), containsPair('email', 'prince@example.com'));
      expect(cubit.state.status, EditProfileStatus.saved);
    },
  );

  blocTest<EditProfileCubit, EditProfileState>(
    'reports a failed save',
    build: () {
      final repository = MockProfileRepository();
      when(
        () => repository.updateProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          phone: any(named: 'phone'),
        ),
      ).thenThrow(const ProfileFailure('You seem to be offline'));
      return EditProfileCubit(repository: repository, uid: 'prince');
    },
    act: (cubit) => cubit.save(name: 'Prince', phone: '0788412890'),
    expect: () => [
      const EditProfileState(status: EditProfileStatus.saving),
      const EditProfileState(
        status: EditProfileStatus.failure,
        errorMessage: 'You seem to be offline',
      ),
    ],
  );
}
