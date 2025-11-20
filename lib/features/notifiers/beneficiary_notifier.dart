import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/beneficiary_models.dart';
import 'package:valarpay/features/repositories/beneficiary_repository.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart'
    show apiClientProvider, userNotifierProvider;

class BeneficiaryNotifier extends StateNotifier<DataState<Beneficiary>> {
  final BeneficiaryRepository _repository;
  final Ref _ref;

  BeneficiaryNotifier(this._repository, this._ref)
    : super(DataState<Beneficiary>.initial());

  Future<void> getBeneficiaries({
    required String category,
    required String transferType,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final user = _ref.read(userNotifierProvider).data?.first;
      final userId = user?.id;
      log('Fetching beneficiaries for userId: $userId');

      final response = await _repository.getBeneficiaries(
        category: category,
        transferType: transferType,
        userId: userId,
      );

      state = state.copyWith(
        isInitialLoading: false,
        data: response.data,
        isDataAvailable: response.data.isNotEmpty,
        message: response.message,
      );
    } catch (e, stack) {
      log('[BeneficiaryNotifier getBeneficiaries Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to get beneficiaries: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<Beneficiary>.initial();
}

final beneficiaryRepositoryProvider = Provider(
  (ref) => BeneficiaryRepository(ref.read(apiClientProvider)),
);

final beneficiaryNotifierProvider = StateNotifierProvider<
  BeneficiaryNotifier,
  DataState<Beneficiary>
>((ref) => BeneficiaryNotifier(ref.read(beneficiaryRepositoryProvider), ref));
