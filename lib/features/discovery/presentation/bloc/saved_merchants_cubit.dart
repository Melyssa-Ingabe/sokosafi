import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/discovery/domain/entities/saved_merchant.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';
import 'package:sokosafi/features/discovery/domain/repositories/saved_merchants_repository.dart';

part 'saved_merchants_state.dart';

/// One cubit for the whole app, so the heart on a product and the Saved
/// Merchants screen always show the same list. It follows the signed-in
/// user and empties itself on logout.
class SavedMerchantsCubit extends Cubit<SavedMerchantsState> {
  SavedMerchantsCubit({required this._repository})
    : super(const SavedMerchantsState());

  final SavedMerchantsRepository _repository;
  StreamSubscription<List<SavedMerchant>>? _subscription;
  String? _uid;

  /// Starts watching [uid]'s saved businesses, or clears them when nobody
  /// is signed in.
  void watchFor(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _subscription?.cancel();
    if (uid == null) {
      emit(const SavedMerchantsState());
      return;
    }
    emit(const SavedMerchantsState(status: SavedMerchantsStatus.loading));
    _subscription = _repository
        .watchSavedMerchants(uid)
        .listen(
          (merchants) => emit(
            state.copyWith(
              status: SavedMerchantsStatus.ready,
              merchants: merchants,
            ),
          ),
          onError: (Object error) => emit(
            state.copyWith(
              status: SavedMerchantsStatus.failure,
              errorMessage: _messageFor(error),
            ),
          ),
        );
  }

  /// Saves [business] if it is not saved yet, otherwise removes it.
  Future<void> toggle(Business business) async {
    final uid = _uid;
    if (uid == null || state.pendingIds.contains(business.id)) return;
    final wasSaved = state.isSaved(business.id);
    emit(state.copyWith(pendingIds: {...state.pendingIds, business.id}));
    try {
      if (wasSaved) {
        await _repository.remove(uid: uid, businessId: business.id);
      } else {
        await _repository.save(uid: uid, businessId: business.id);
      }
      emit(
        state.copyWith(
          feedback: SavedMerchantsFeedback(
            wasSaved
                ? 'Removed ${business.name} from saved'
                : 'Saved ${business.name}',
          ),
        ),
      );
    } on Exception catch (error) {
      emit(
        state.copyWith(
          feedback: SavedMerchantsFeedback(_messageFor(error), isError: true),
        ),
      );
    } finally {
      emit(
        state.copyWith(pendingIds: {...state.pendingIds}..remove(business.id)),
      );
    }
  }

  static String _messageFor(Object error) => error is DiscoveryFailure
      ? error.message
      : DiscoveryFailure.genericMessage;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
