import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/cable_models.dart';
import 'package:valarpay/features/repositories/cable_repository.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

class CablePlansNotifier extends StateNotifier<DataState<CablePlanInfo>> {
  final CableRepository _repository;

  CablePlansNotifier(this._repository)
    : super(DataState<CablePlanInfo>.initial());

  Future<void> getPlans({required String currency}) async {
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    try {
      final res = await _repository.getCablePlans(currency: currency);
      state = state.copyWith(
        isInitialLoading: false,
        data: res.data,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[CablePlansNotifier getPlans Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load plans: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<CablePlanInfo>.initial();
}

class CableVariationNotifier
    extends StateNotifier<DataState<CableVariationInfo>> {
  final CableRepository _repository;

  CableVariationNotifier(this._repository)
    : super(DataState<CableVariationInfo>.initial());

  Future<void> getVariations({required String billerCode}) async {
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    try {
      final res = await _repository.getCableVariation(billerCode: billerCode);
      state = state.copyWith(
        isInitialLoading: false,
        data: res.data,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[CableVariationNotifier getVariations Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load variations: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<CableVariationInfo>.initial();
}

class CablePaymentNotifier
    extends StateNotifier<DataState<CablePaymentResponse>> {
  final CableRepository _repository;

  CablePaymentNotifier(this._repository)
    : super(DataState<CablePaymentResponse>.initial());

  Future<VerifyCableResponse> verifyNumber(VerifyCableRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.verifyCableNumber(request);
      state = state.copyWith(isInitialLoading: false, message: res.message);
      return res;
    } catch (e, stack) {
      log('[CablePaymentNotifier verifyNumber Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> payCable(CablePayRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.payCable(request);
      state = state.copyWith(
        isInitialLoading: false,
        data: [res],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[CablePaymentNotifier payCable Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Payment failed: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<CablePaymentResponse>.initial();
}

// Providers
final cableRepositoryProvider = Provider(
  (ref) => CableRepository(ref.read(apiClientProvider)),
);

final cablePlansNotifierProvider =
    StateNotifierProvider<CablePlansNotifier, DataState<CablePlanInfo>>(
      (ref) => CablePlansNotifier(ref.read(cableRepositoryProvider)),
    );

final cableVariationNotifierProvider = StateNotifierProvider<
  CableVariationNotifier,
  DataState<CableVariationInfo>
>((ref) => CableVariationNotifier(ref.read(cableRepositoryProvider)));

final cablePaymentNotifierProvider = StateNotifierProvider<
  CablePaymentNotifier,
  DataState<CablePaymentResponse>
>((ref) => CablePaymentNotifier(ref.read(cableRepositoryProvider)));

// UI State Providers
final cableSelectedProviderProvider = StateProvider<CablePlanInfo?>(
  (ref) => null,
);
final cableSelectedPlanProvider = StateProvider<String?>((ref) => null);

class CableBeneficiaryNotifier
    extends StateNotifier<DataState<CableBeneficiary>> {
  final CableRepository _repository;

  CableBeneficiaryNotifier(this._repository)
    : super(DataState<CableBeneficiary>.initial());

  Future<void> getCableBeneficiaries() async {
    if (state.data == null || state.data!.isEmpty) {
      state = state.copyWith(isInitialLoading: true, message: null);
    }
    try {
      final res = await _repository.getCableBeneficiaries();
      state = state.copyWith(
        isInitialLoading: false,
        data: res.data,
        isDataAvailable: true,
        message: res.message,
      );
      log('[CableBeneficiaryNotifier] Loaded ${res.data.length} beneficiaries');
    } catch (e, stack) {
      log('[CableBeneficiaryNotifier getCableBeneficiaries Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load beneficiaries: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<CableBeneficiary>.initial();
}

final cableBeneficiaryNotifierProvider = StateNotifierProvider<
  CableBeneficiaryNotifier,
  DataState<CableBeneficiary>
>((ref) => CableBeneficiaryNotifier(ref.read(cableRepositoryProvider)));
