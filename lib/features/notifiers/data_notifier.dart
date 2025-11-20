import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/network_provider.dart';
import 'package:valarpay/features/models/data_models.dart';
import 'package:valarpay/features/repositories/data_repository.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

/// Data repository provider
final dataRepositoryProvider = Provider<DataRepository>((ref) {
  return DataRepository(ref.read(apiClientProvider));
});

/// Provider: network providers list (NetworkProvider)
class DataProvidersNotifier extends StateNotifier<DataState<NetworkProvider>> {
  final DataRepository _repository;

  DataProvidersNotifier(this._repository)
    : super(DataState<NetworkProvider>.initial());

  Future<void> fetchProviders() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getDataNetworkProviders();
      state = state.copyWith(
        isInitialLoading: false,
        data: res.providers,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[DataProvidersNotifier fetchProviders] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load providers: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<NetworkProvider>.initial();
}

/// Provider: data plans (DataPlanInfo)
class DataPlansNotifier extends StateNotifier<DataState<DataPlanInfo>> {
  final DataRepository _repository;

  DataPlansNotifier(this._repository)
    : super(DataState<DataPlanInfo>.initial());

  Future<void> getPlans({
    required String phone,
    required String currency,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getDataPlan(
        phone: phone,
        currency: currency,
      );
      state = state.copyWith(
        isInitialLoading: false,
        data: res.plans,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[DataPlansNotifier getPlans] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load plans: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<DataPlanInfo>.initial();
}

/// Provider: data variation (DataPlan)
class DataVariationNotifier extends StateNotifier<DataState<DataPlan>> {
  final DataRepository _repository;

  DataVariationNotifier(this._repository)
    : super(DataState<DataPlan>.initial());

  Future<void> getVariation({required int operatorId}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getDataVariation(operatorId: operatorId);
      state = state.copyWith(
        isInitialLoading: false,
        data: [res.data],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[DataVariationNotifier getVariation] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load variation: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<DataPlan>.initial();
}

/// Provider: data purchase
class DataPurchaseNotifier
    extends StateNotifier<DataState<DataPurchaseResponse>> {
  final DataRepository _repository;

  DataPurchaseNotifier(this._repository)
    : super(DataState<DataPurchaseResponse>.initial());

  Future<void> purchase(DataPurchaseRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.payData(request);
      state = state.copyWith(
        isInitialLoading: false,
        data: [res],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[DataPurchaseNotifier purchase] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Purchase failed: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<DataPurchaseResponse>.initial();
}

/// Provider: data beneficiaries
class DataBeneficiaryNotifier
    extends StateNotifier<DataState<DataBeneficiary>> {
  final DataRepository _repository;

  DataBeneficiaryNotifier(this._repository)
    : super(DataState<DataBeneficiary>.initial());

  Future<void> getDataBeneficiaries() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final response = await _repository.getDataBeneficiaries(userId: '');

      state = state.copyWith(
        isInitialLoading: false,
        data: response.data,
        isDataAvailable: response.data.isNotEmpty,
        message: response.data.isEmpty ? null : response.message,
      );
    } catch (e, stack) {
      log('[DataBeneficiaryNotifier getDataBeneficiaries] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to get data beneficiaries: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<DataBeneficiary>.initial();
}

// Riverpod providers
final dataProvidersNotifierProvider =
    StateNotifierProvider<DataProvidersNotifier, DataState<NetworkProvider>>(
      (ref) => DataProvidersNotifier(ref.read(dataRepositoryProvider)),
    );

final dataPlansNotifierProvider =
    StateNotifierProvider<DataPlansNotifier, DataState<DataPlanInfo>>(
      (ref) => DataPlansNotifier(ref.read(dataRepositoryProvider)),
    );

final dataVariationNotifierProvider =
    StateNotifierProvider<DataVariationNotifier, DataState<DataPlan>>(
      (ref) => DataVariationNotifier(ref.read(dataRepositoryProvider)),
    );

final dataPurchaseNotifierProvider = StateNotifierProvider<
  DataPurchaseNotifier,
  DataState<DataPurchaseResponse>
>((ref) => DataPurchaseNotifier(ref.read(dataRepositoryProvider)));

final dataBeneficiaryNotifierProvider =
    StateNotifierProvider<DataBeneficiaryNotifier, DataState<DataBeneficiary>>(
      (ref) => DataBeneficiaryNotifier(ref.read(dataRepositoryProvider)),
    );

/// UI StateProviders for data screen selections
final dataSelectedNetworkProvider = StateProvider<String>((ref) => '');
final dataSelectedOperatorIdProvider = StateProvider<int>((ref) => 0);
final dataSelectedPlanProvider = StateProvider<String>((ref) => '');
