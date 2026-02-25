import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/network_provider.dart';
import 'package:valarpay/features/models/airtime_models.dart';
import 'package:valarpay/features/repositories/airtime_repository.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

final airtimeRepositoryProvider = Provider<AirtimeRepository>((ref) {
  return AirtimeRepository(ref.read(apiClientProvider));
});

class AirtimeProvidersNotifier
    extends StateNotifier<DataState<NetworkProvider>> {
  final AirtimeRepository _repository;

  AirtimeProvidersNotifier(this._repository)
    : super(DataState<NetworkProvider>.initial());

  Future<void> fetchProviders() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getAirtimeNetworkProviders();
      state = state.copyWith(
        data: res.providers,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[AirtimeProvidersNotifier fetchProviders] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: 'Failed to load providers: ${e.toString()}',
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  void reset() => state = DataState<NetworkProvider>.initial();
}

class AirtimePlanNotifier extends StateNotifier<DataState<AirtimePlan>> {
  final AirtimeRepository _repository;

  AirtimePlanNotifier(this._repository)
    : super(DataState<AirtimePlan>.initial());

  Future<void> getPlan({
    required String phone,
    required String currency,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getAirtimePlan(phone: phone, currency: currency);
      state = state.copyWith(
        data: res, // res is List<AirtimePlan>
        isDataAvailable: res.isNotEmpty,
        message: 'Success',
      );
    } catch (e, stack) {
      log('[AirtimePlanNotifier getPlan] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: 'Failed to load plan: ${e.toString()}',
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<void> getVariation({required String billerId}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getAirtimeVariation(billerId: billerId);
      state = state.copyWith(
        data: [res.plan],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[AirtimePlanNotifier getVariation] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: 'Failed to load variation: ${e.toString()}',
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<void> getInternationalPlan({required String phone}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getInternationalPlan(phone: phone);
      state = state.copyWith(
        data: [res.plan],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[AirtimePlanNotifier getInternationalPlan] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: 'Failed to load international plan: ${e.toString()}',
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  void reset() => state = DataState<AirtimePlan>.initial();
}

class AirtimePurchaseNotifier
    extends StateNotifier<DataState<AirtimePurchaseResponse>> {
  final AirtimeRepository _repository;

  AirtimePurchaseNotifier(this._repository)
    : super(DataState<AirtimePurchaseResponse>.initial());

  Future<void> purchase(AirtimePurchaseRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.payAirtime(request);

      if (res.success == true) {
        state = state.copyWith(
          data: [res],
          isDataAvailable: true,
          message: res.message ?? 'Airtime purchase successful',
        );
      } else {
        state = state.copyWith(
          isDataAvailable: false,
          message: res.message ?? 'Airtime purchase failed',
        );
      }
    } catch (e, stack) {
      log('[AirtimePurchaseNotifier purchase] $e\n$stack');
      state = state.copyWith(isDataAvailable: false, message: e.toString());
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  void reset() => state = DataState<AirtimePurchaseResponse>.initial();
}

class InternationalFxNotifier
    extends StateNotifier<DataState<InternationalFxRate>> {
  final AirtimeRepository _repository;

  InternationalFxNotifier(this._repository)
    : super(DataState<InternationalFxRate>.initial());

  Future<void> getFxRate({
    required double amount,
    required String fromCurrency,
    required int operatorId,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getInternationalFxRate(
        amount: amount,
        fromCurrency: fromCurrency,
        operatorId: operatorId,
      );
      state = state.copyWith(
        data: [res.data],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[InternationalFxNotifier getFxRate] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: 'Failed to fetch FX rate: ${e.toString()}',
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  void reset() => state = DataState<InternationalFxRate>.initial();
}

class InternationalPurchaseNotifier
    extends StateNotifier<DataState<AirtimePurchaseResponse>> {
  final AirtimeRepository _repository;

  InternationalPurchaseNotifier(this._repository)
    : super(DataState<AirtimePurchaseResponse>.initial());

  Future<void> purchase(AirtimePurchaseRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.payInternationalAirtime(request);
      state = state.copyWith(
        data: [res],
        isDataAvailable: true,
        message: res.message ?? 'International airtime purchase successful',
      );
    } catch (e, stack) {
      log('[InternationalPurchaseNotifier purchase] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: 'Purchase failed: ${e.toString()}',
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  void reset() => state = DataState<AirtimePurchaseResponse>.initial();
}

final airtimeProvidersNotifierProvider =
    StateNotifierProvider<AirtimeProvidersNotifier, DataState<NetworkProvider>>(
      (ref) => AirtimeProvidersNotifier(ref.read(airtimeRepositoryProvider)),
    );

final airtimePlanNotifierProvider =
    StateNotifierProvider<AirtimePlanNotifier, DataState<AirtimePlan>>(
      (ref) => AirtimePlanNotifier(ref.read(airtimeRepositoryProvider)),
    );

final airtimePurchaseNotifierProvider = StateNotifierProvider<
  AirtimePurchaseNotifier,
  DataState<AirtimePurchaseResponse>
>((ref) => AirtimePurchaseNotifier(ref.read(airtimeRepositoryProvider)));

final internationalFxNotifierProvider = StateNotifierProvider<
  InternationalFxNotifier,
  DataState<InternationalFxRate>
>((ref) => InternationalFxNotifier(ref.read(airtimeRepositoryProvider)));

final internationalPurchaseNotifierProvider = StateNotifierProvider<
  InternationalPurchaseNotifier,
  DataState<AirtimePurchaseResponse>
>((ref) => InternationalPurchaseNotifier(ref.read(airtimeRepositoryProvider)));

class AirtimeBeneficiaryNotifier
    extends StateNotifier<DataState<AirtimeBeneficiary>> {
  final AirtimeRepository _repository;
  final Ref _ref;

  AirtimeBeneficiaryNotifier(this._repository, this._ref)
    : super(DataState<AirtimeBeneficiary>.initial());

  Future<void> getAirtimeBeneficiaries() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final user = _ref.read(userNotifierProvider).data?.first;
      final userId = user?.id ?? '';
      
      final response = await _repository.getAirtimeBeneficiaries(userId: userId);

      state = state.copyWith(
        isInitialLoading: false,
        data: response.data,
        isDataAvailable: response.data.isNotEmpty,
        message: response.data.isEmpty ? null : response.message,
      );
    } catch (e, stack) {
      log('[AirtimeBeneficiaryNotifier getAirtimeBeneficiaries] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to get airtime beneficiaries: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<AirtimeBeneficiary>.initial();
}

final airtimeBeneficiaryNotifierProvider = StateNotifierProvider<
  AirtimeBeneficiaryNotifier,
  DataState<AirtimeBeneficiary>
>((ref) => AirtimeBeneficiaryNotifier(ref.read(airtimeRepositoryProvider), ref));
