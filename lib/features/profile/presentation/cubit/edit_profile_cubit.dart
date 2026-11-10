import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/profile/domain/failures/profile_failure.dart';
import 'package:sokosafi/features/profile/domain/repositories/profile_repository.dart';

enum EditProfileStatus { editing, saving, saved, failure }

class EditProfileState extends Equatable {
  const EditProfileState({
    this.status = EditProfileStatus.editing,
    this.errorMessage,
  });

  final EditProfileStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];
}

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({required this._repository, required this._uid})
    : super(const EditProfileState());

  final ProfileRepository _repository;
  final String _uid;

  Future<void> save({required String name, required String phone}) async {
    if (state.status == EditProfileStatus.saving) return;
    emit(const EditProfileState(status: EditProfileStatus.saving));
    try {
      await _repository.updateProfile(uid: _uid, name: name, phone: phone);
      emit(const EditProfileState(status: EditProfileStatus.saved));
    } on ProfileFailure catch (failure) {
      emit(
        EditProfileState(
          status: EditProfileStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }
}
