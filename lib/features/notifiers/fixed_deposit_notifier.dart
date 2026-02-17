import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/fixed_deposit_models.dart';
import 'package:valarpay/features/repositories/fixed_deposit_repository.dart';
import 'package:valarpay/core/network/api_client.dart';

final fixedDepositRepositoryProvider = Provider<FixedDepositRepository>((ref) {
  return FixedDepositRepository(ref.read(apiClientProvider));
});

class FixedDepositPlanNotifier extends StateNotifier<DataState<FixedDepositPlan>> {
  final FixedDepositRepository _repository;

  FixedDepositPlanNotifier(this._repository) : super(DataState<FixedDepositPlan>.initial());

  Future<void> fetchPlans() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final plans = await _repository.getAvailablePlans();
      state = state.copyWith(
        data: plans,
        isDataAvailable: plans.isNotEmpty,
        message: 'Plans loaded',
      );
    } catch (e, stack) {
      log('[FixedDepositPlanNotifier fetchPlans] $e\n$stack');
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

class FixedDepositNotifier extends StateNotifier<DataState<FixedDeposit>> {
  final FixedDepositRepository _repository;

  FixedDepositNotifier(this._repository) : super(DataState<FixedDeposit>.initial());

  Future<void> fetchUserDeposits() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final deposits = await _repository.getUserDeposits();
      state = state.copyWith(
        data: deposits,
        isDataAvailable: deposits.isNotEmpty,
        message: 'Deposits loaded',
      );
    } catch (e, stack) {
      log('[FixedDepositNotifier fetchUserDeposits] $e\n$stack');
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<bool> createDeposit(CreateFixedDepositRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final newDeposit = await _repository.createFixedDeposit(request);
      state = state.copyWith(
        data: [newDeposit, ...(state.data ?? [])],
        isDataAvailable: true,
        message: 'Fixed deposit created successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(message: e.toString());
      return false;
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}
class FixedDepositActionNotifier extends StateNotifier<AsyncValue<void>> {
  final FixedDepositRepository _repository;

  FixedDepositActionNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> earlyWithdraw(String depositId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.earlyWithdrawal(depositId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> maturityPayout(String depositId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.maturityPayout(depositId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final fixedDepositActionNotifierProvider = StateNotifierProvider<FixedDepositActionNotifier, AsyncValue<void>>((ref) {
  return FixedDepositActionNotifier(ref.read(fixedDepositRepositoryProvider));
});

final fixedDepositPlanNotifierProvider = StateNotifierProvider<FixedDepositPlanNotifier, DataState<FixedDepositPlan>>((ref) {
  return FixedDepositPlanNotifier(ref.read(fixedDepositRepositoryProvider));
});

final fixedDepositNotifierProvider = StateNotifierProvider<FixedDepositNotifier, DataState<FixedDeposit>>((ref) {
  return FixedDepositNotifier(ref.read(fixedDepositRepositoryProvider));
});
