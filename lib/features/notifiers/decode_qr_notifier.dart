import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/decode_qr_response.dart';
import 'package:valarpay/features/repositories/decode_qr_repository.dart';
import 'package:valarpay/core/network/api_client.dart';

class DecodeQrNotifier extends StateNotifier<DataState<DecodeQrResponse>> {
  final DecodeQrRepository _repository;

  DecodeQrNotifier(this._repository)
      : super(DataState<DecodeQrResponse>.initial());

  Future<void> decodeFromBase64(String base64Data) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      // repository expects the final payload; if base64 was provided we sent
      // it with data:image prefix in the repository previously — keep that
      // behavior by forwarding it as-is.
      final parsed =
          await _repository.decodeQr('data:image/png;base64,$base64Data');
      state = state.copyWith(
          isInitialLoading: false,
          isDataAvailable: true,
          data: [parsed],
          message: 'Success');
    } catch (e, st) {
      log('[DecodeQrNotifier] error: $e\n$st');
      state = state.copyWith(
          isInitialLoading: false,
          isDataAvailable: false,
          message: e.toString());
    }
  }

  Future<void> decodeFromRawString(String qrString) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      // Send raw QR string directly to the API
      final parsed = await _repository.decodeQr(qrString);
      state = state.copyWith(
          isInitialLoading: false,
          isDataAvailable: true,
          data: [parsed],
          message: 'Success');
    } catch (e, st) {
      log('[DecodeQrNotifier] error: $e\n$st');
      state = state.copyWith(
          isInitialLoading: false,
          isDataAvailable: false,
          message: e.toString());
    }
  }

  void reset() => state = DataState<DecodeQrResponse>.initial();
}

final decodeQrRepositoryProvider = Provider<DecodeQrRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return DecodeQrRepository(api);
});

final decodeQrNotifierProvider =
    StateNotifierProvider<DecodeQrNotifier, DataState<DecodeQrResponse>>((ref) {
  final repo = ref.read(decodeQrRepositoryProvider);
  return DecodeQrNotifier(repo);
});
