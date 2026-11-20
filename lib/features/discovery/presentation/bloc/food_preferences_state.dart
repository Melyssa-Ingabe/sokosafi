part of 'food_preferences_cubit.dart';

enum FoodPreferencesStatus { editing, saving, saved, failure }

class FoodPreferencesState extends Equatable {
  const FoodPreferencesState({
    this.status = FoodPreferencesStatus.editing,
    this.selected = const {},
    this.saved = const {},
    this.errorMessage,
  });

  final FoodPreferencesStatus status;

  /// What the customer has ticked on screen.
  final Set<ListingCategory> selected;

  /// What is stored on their profile, to tell whether there is anything
  /// to save.
  final Set<ListingCategory> saved;

  final String? errorMessage;

  bool get hasChanges =>
      selected.length != saved.length || !selected.containsAll(saved);

  bool get isSaving => status == FoodPreferencesStatus.saving;

  FoodPreferencesState copyWith({
    FoodPreferencesStatus? status,
    Set<ListingCategory>? selected,
    Set<ListingCategory>? saved,
    String? errorMessage,
  }) {
    return FoodPreferencesState(
      status: status ?? this.status,
      selected: selected ?? this.selected,
      saved: saved ?? this.saved,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selected, saved, errorMessage];
}
