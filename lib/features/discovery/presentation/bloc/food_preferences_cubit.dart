import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';
import 'package:sokosafi/features/discovery/domain/repositories/food_preferences_repository.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

part 'food_preferences_state.dart';

/// Picks the food categories the feed shows first.
class FoodPreferencesCubit extends Cubit<FoodPreferencesState> {
  FoodPreferencesCubit({
    required this._repository,
    required this._uid,
    required List<String> current,
  }) : super(_initialState(current));

  final FoodPreferencesRepository _repository;
  final String _uid;

  /// Unknown names are skipped rather than read as a default category, so
  /// an old or hand-edited profile never ticks something by mistake.
  static FoodPreferencesState _initialState(List<String> current) {
    final stored = {
      for (final category in ListingCategory.values)
        if (current.contains(category.name)) category,
    };
    return FoodPreferencesState(selected: stored, saved: stored);
  }

  void toggle(ListingCategory category) {
    if (state.isSaving) return;
    final selected = {...state.selected};
    if (!selected.remove(category)) selected.add(category);
    emit(
      state.copyWith(status: FoodPreferencesStatus.editing, selected: selected),
    );
  }

  Future<void> save() async {
    if (state.isSaving || !state.hasChanges) return;
    emit(state.copyWith(status: FoodPreferencesStatus.saving));
    try {
      await _repository.save(uid: _uid, categories: state.selected);
      emit(
        state.copyWith(
          status: FoodPreferencesStatus.saved,
          saved: state.selected,
        ),
      );
    } on DiscoveryFailure catch (failure) {
      emit(
        state.copyWith(
          status: FoodPreferencesStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }
}
