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

  Future<bool> submitBasicKyc(BvnVerificationRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.verifyKyc(request);
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        data: [res],
        message: res.message,
      );
      return true;
    } catch (e, stack) {
      log('[WalletNotifier submitBasicKyc] error: $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
      return false;
    }
  }

  Future<bool> submitBiometricKyc({
    required String selfieImage,
    required List<String> livenessImages,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.submitBiometricKyc(
        selfieImage: selfieImage,
        livenessImages: livenessImages,
      );
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        data: [res],
        message: res.message,
      );
      return true;
    } catch (e, stack) {
      log('[WalletNotifier biometricKyc] error: $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
      return false;
    }
  }

  Future<bool> submitSmartSelfieAuth({
    required String selfieImage,
    required List<String> livenessImages,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.submitSmartSelfieAuth(
        selfieImage: selfieImage,
        livenessImages: livenessImages,
      );
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        data: [res],
        message: res.message,
      );
      return true;
    } catch (e, stack) {
      log('[WalletNotifier smartSelfieAuth] error: $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
      return false;
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
