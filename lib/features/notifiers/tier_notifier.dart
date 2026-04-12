import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/user_tier.dart';
import 'package:valarpay/features/repositories/user_repository.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

class TierNotifier extends StateNotifier<DataState<UserTierData>> {
  final UserRepository _repository;

  TierNotifier(this._repository) : super(DataState<UserTierData>.initial());

  Future<void> getUserTier() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final response = await _repository.getUserTier();
      state = state.copyWith(
        isInitialLoading: false,
        data: [response.data],
        isDataAvailable: true,
      );
    } catch (e, stack) {
      log('[TierNotifier Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

final tierNotifierProvider =
    StateNotifierProvider<TierNotifier, DataState<UserTierData>>((ref) {
  final repository = ref.read(userRepositoryProvider);
  return TierNotifier(repository);
});
