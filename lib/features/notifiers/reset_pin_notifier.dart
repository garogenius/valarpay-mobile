// ignore: file_names
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/reset_pin_model.dart';
import 'package:valarpay/features/repositories/reset_pin_repository.dart';

class ResetPinNotifier extends StateNotifier<DataState<ResetPinRequest>> {
  final ResetPinRepository _repository;

  ResetPinNotifier(this._repository) : super(DataState<ResetPinRequest>.initial());

  Future<void> forgotPin() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.forgotPin();
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[ResetPinNotifier Forgot Password Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
    }
  }

   Future<void> resetPin(ResetPinRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.resetPin(request);
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[ResetPinNotifier Reset Password Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
    }
  }
  void reset() => state = DataState<ResetPinRequest>.initial();
}

// 🔹 Providers

final resetPinRepositoryProvider = Provider(
  (ref) => ResetPinRepository(ref.read(apiClientProvider)),
);

final resetPinNotifierProvider =
    StateNotifierProvider<ResetPinNotifier, DataState<ResetPinRequest>>(
      (ref) => ResetPinNotifier(ref.read(resetPinRepositoryProvider)),
    );
