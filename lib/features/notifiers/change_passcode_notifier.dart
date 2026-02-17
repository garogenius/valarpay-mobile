import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/change_passcode_models.dart';
import 'package:valarpay/features/repositories/change_passcode_repository.dart';
import 'package:valarpay/core/network/api_client.dart';

class ChangePasscodeNotifier
    extends StateNotifier<DataState<ChangePasscodeResponse>> {
  final ChangePasscodeRepository _repository;

  ChangePasscodeNotifier(this._repository)
      : super(DataState<ChangePasscodeResponse>.initial());

  Future<void> changePasscode({
    required String oldPasscode,
    required String newPasscode,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);

    try {
      final request = ChangePasscodeRequest(
        oldPasscode: oldPasscode,
        newPasscode: newPasscode,
      );

      final response = await _repository.changePasscode(request);

      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        data: [response],
        message: response.message,
      );
    } catch (e) {
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void reset() => state = DataState<ChangePasscodeResponse>.initial();
}

final changePasscodeRepositoryProvider =
    Provider<ChangePasscodeRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ChangePasscodeRepository(apiClient);
});

final changePasscodeNotifierProvider = StateNotifierProvider<
    ChangePasscodeNotifier, DataState<ChangePasscodeResponse>>((ref) {
  final repository = ref.read(changePasscodeRepositoryProvider);
  return ChangePasscodeNotifier(repository);
});
