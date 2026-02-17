import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/change_password_models.dart';
import 'package:valarpay/features/repositories/change_password_repository.dart';
import 'package:valarpay/core/network/api_client.dart';

class ChangePasswordNotifier
    extends StateNotifier<DataState<ChangePasswordResponse>> {
  final ChangePasswordRepository _repository;

  ChangePasswordNotifier(this._repository)
      : super(DataState<ChangePasswordResponse>.initial());

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);

    try {
      final request = ChangePasswordRequest(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      final response = await _repository.changePassword(request);

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

  void reset() => state = DataState<ChangePasswordResponse>.initial();
}

final changePasswordRepositoryProvider =
    Provider<ChangePasswordRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ChangePasswordRepository(apiClient);
});

final changePasswordNotifierProvider = StateNotifierProvider<
    ChangePasswordNotifier, DataState<ChangePasswordResponse>>((ref) {
  final repository = ref.read(changePasswordRepositoryProvider);
  return ChangePasswordNotifier(repository);
});
