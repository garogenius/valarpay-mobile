import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/savings_models.dart';
import 'package:valarpay/features/repositories/savings_repository.dart';
import 'package:valarpay/core/network/api_client.dart';

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  return SavingsRepository(ref.read(apiClientProvider));
});

class SavingsProductNotifier extends StateNotifier<DataState<SavingsProduct>> {
  final SavingsRepository _repository;

  SavingsProductNotifier(this._repository) : super(DataState<SavingsProduct>.initial());

  Future<void> fetchProducts() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final products = await _repository.getSavingsProducts();
      state = state.copyWith(
        data: products,
        isDataAvailable: products.isNotEmpty,
        message: 'Products loaded',
      );
    } catch (e, stack) {
      log('[SavingsProductNotifier fetchProducts] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

class SavingsPlanNotifier extends StateNotifier<DataState<SavingsPlan>> {
  final SavingsRepository _repository;

  SavingsPlanNotifier(this._repository) : super(DataState<SavingsPlan>.initial());

  Future<void> fetchUserPlans() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final plans = await _repository.getUserSavingsPlans();
      state = state.copyWith(
        data: plans,
        isDataAvailable: plans.isNotEmpty,
        message: 'Plans loaded',
      );
    } catch (e, stack) {
      log('[SavingsPlanNotifier fetchUserPlans] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<void> getPlanDetails(String planId) async {
    // For single plan detail, we can either update the data list or have another notifier
    // Given the pattern, updating the list or replacing it might be tricky if we want to keep the list.
    // Let's just fetch it and if found in list, update it.
    try {
      final detail = await _repository.getSavingsPlanDetails(planId);
      final currentData = state.data ?? [];
      final index = currentData.indexWhere((p) => p.id == planId);
      if (index != -1) {
        currentData[index] = detail;
        state = state.copyWith(data: [...currentData]);
      } else {
        state = state.copyWith(data: [detail, ...currentData]);
      }
    } catch (e) {
      log('[SavingsPlanNotifier getPlanDetails] $e');
    }
  }

  Future<bool> createPlan(CreateSavingsPlanRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final newPlan = await _repository.createSavingsPlan(request);
      state = state.copyWith(
        data: [newPlan, ...(state.data ?? [])],
        isDataAvailable: true,
        message: 'Savings plan created successfully',
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

class SavingsActionNotifier extends StateNotifier<AsyncValue<void>> {
  final SavingsRepository _repository;

  SavingsActionNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> fundPlan(FundSavingsPlanRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.fundSavingsPlan(request);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> withdrawPlan(String planId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.withdrawSavingsPlan(planId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final savingsProductNotifierProvider = StateNotifierProvider<SavingsProductNotifier, DataState<SavingsProduct>>((ref) {
  return SavingsProductNotifier(ref.read(savingsRepositoryProvider));
});

final savingsPlanNotifierProvider = StateNotifierProvider<SavingsPlanNotifier, DataState<SavingsPlan>>((ref) {
  return SavingsPlanNotifier(ref.read(savingsRepositoryProvider));
});

final savingsActionNotifierProvider = StateNotifierProvider<SavingsActionNotifier, AsyncValue<void>>((ref) {
  return SavingsActionNotifier(ref.read(savingsRepositoryProvider));
});
