import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/api_response.dart';
import 'package:valarpay/features/models/bvn_verification_request.dart';
import 'package:valarpay/features/repositories/wallet_repository.dart';
import 'package:valarpay/core/network/api_client.dart';

class WalletNotifier extends StateNotifier<DataState<ApiResponse>> {
  final WalletRepository _repository;

  WalletNotifier(this._repository) : super(DataState<ApiResponse>.initial());

  Future<void> verifyBvnAndSetupWallet(BvnVerificationRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.verifyBVN(request);
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        data: [res],
        message: res.message,
      );
    } catch (e, stack) {
      log('[WalletNotifier] error: $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
    }
  }

  /// Create multi-currency account
  Future<void> createMultiCurrencyAccount({
    required String currency,
    required String label,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.createMultiCurrencyAccount(
        currency: currency,
        label: label,
      );
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        data: [res],
        message: res.message,
      );
    } catch (e, stack) {
      log('[WalletNotifier] create account error: $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
      rethrow;
    }
  }

  void reset() => state = DataState<ApiResponse>.initial();
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return WalletRepository(api);
});

final walletNotifierProvider =
StateNotifierProvider<WalletNotifier, DataState<ApiResponse>>((ref) {
  final repo = ref.read(walletRepositoryProvider);
  return WalletNotifier(repo);
});
