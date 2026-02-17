import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/easylife_models.dart';
import 'package:valarpay/features/repositories/easylife_repository.dart';
import 'package:valarpay/core/network/api_client.dart';

final easyLifeRepositoryProvider = Provider<EasyLifeRepository>((ref) {
  return EasyLifeRepository(ref.read(apiClientProvider));
});

class EasyLifeProductNotifier extends StateNotifier<DataState<EasyLifeProduct>> {
  final EasyLifeRepository _repository;

  EasyLifeProductNotifier(this._repository) : super(DataState<EasyLifeProduct>.initial());

  Future<void> fetchProductInfo() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final product = await _repository.getProductInfo();
      state = state.copyWith(
        data: [product],
        isDataAvailable: true,
        message: 'Product info loaded',
      );
    } catch (e, stack) {
      log('[EasyLifeProductNotifier fetchProductInfo] $e\n$stack');
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

class EasyLifePlanNotifier extends StateNotifier<DataState<EasyLifePlan>> {
  final EasyLifeRepository _repository;

  EasyLifePlanNotifier(this._repository) : super(DataState<EasyLifePlan>.initial());

  Future<void> fetchUserPlans() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final plans = await _repository.getUserPlans();
      state = state.copyWith(
        data: plans,
        isDataAvailable: plans.isNotEmpty,
        message: 'Plans loaded',
      );
    } catch (e, stack) {
      log('[EasyLifePlanNotifier fetchUserPlans] $e\n$stack');
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<bool> createPlan(CreateEasyLifePlanRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final newPlan = await _repository.createPlan(request);
      state = state.copyWith(
        data: [newPlan, ...(state.data ?? [])],
        isDataAvailable: true,
        message: 'Plan created successfully',
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

final easyLifeProductNotifierProvider = StateNotifierProvider<EasyLifeProductNotifier, DataState<EasyLifeProduct>>((ref) {
  return EasyLifeProductNotifier(ref.read(easyLifeRepositoryProvider));
});

final easyLifePlanNotifierProvider = StateNotifierProvider<EasyLifePlanNotifier, DataState<EasyLifePlan>>((ref) {
  return EasyLifePlanNotifier(ref.read(easyLifeRepositoryProvider));
});

class EasyLifeActionNotifier extends StateNotifier<AsyncValue<void>> {
  final EasyLifeRepository _repository;

  EasyLifeActionNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> fundPlan(FundEasyLifePlanRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _repository.fundPlan(request);
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
      await _repository.withdrawPlan(planId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final easyLifeActionNotifierProvider = StateNotifierProvider<EasyLifeActionNotifier, AsyncValue<void>>((ref) {
  return EasyLifeActionNotifier(ref.read(easyLifeRepositoryProvider));
});
