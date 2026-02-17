import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/create_passcode_request.dart';
import 'package:valarpay/features/models/create_passcode_response.dart';
import 'package:valarpay/features/repositories/auth_repository.dart';

class PasscodeNotifier
    extends StateNotifier<DataState<CreatePasscodeResponse>> {
  final AuthRepository _repository;

  PasscodeNotifier(this._repository)
      : super(DataState<CreatePasscodeResponse>.initial());

  /// Create a new passcode
  Future<void> createPasscode(CreatePasscodeRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.createPasscode(request);
      state = state.copyWith(
        isInitialLoading: false,
        data: [res],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[PasscodeNotifier Create Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
    }
  }

  void reset() => state = DataState<CreatePasscodeResponse>.initial();
}

// 🔹 Providers

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.read(apiClientProvider)),
);

final passcodeNotifierProvider =
    StateNotifierProvider<PasscodeNotifier, DataState<CreatePasscodeResponse>>(
  (ref) => PasscodeNotifier(ref.read(authRepositoryProvider)),
);
