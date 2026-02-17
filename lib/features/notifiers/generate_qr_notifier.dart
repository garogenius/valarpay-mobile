import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/generate_qr_response.dart';
import 'package:valarpay/features/repositories/generate_qr_repository.dart';
import 'package:valarpay/core/network/api_client.dart';

class GenerateQrNotifier extends StateNotifier<DataState<GenerateQrResponse>> {
  final GenerateQrRepository _repository;

  GenerateQrNotifier(this._repository)
      : super(DataState<GenerateQrResponse>.initial());

  Future<void> generate(double amount) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.generate(amount: amount);
      state = state.copyWith(
          isInitialLoading: false,
          isDataAvailable: true,
          data: [res],
          message: res.message);
    } catch (e, st) {
      log('[GenerateQrNotifier] error: $e\n$st');
      state = state.copyWith(
          isInitialLoading: false,
          isDataAvailable: false,
          message: e.toString());
    }
  }

  void reset() => state = DataState<GenerateQrResponse>.initial();
}

final generateQrRepositoryProvider = Provider<GenerateQrRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return GenerateQrRepository(api);
});

final generateQrNotifierProvider =
    StateNotifierProvider<GenerateQrNotifier, DataState<GenerateQrResponse>>(
        (ref) {
  final repo = ref.read(generateQrRepositoryProvider);
  return GenerateQrNotifier(repo);
});
