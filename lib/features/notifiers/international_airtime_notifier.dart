import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/international_airtime_models.dart';
import 'package:valarpay/features/repositories/international_airtime_repository.dart';

final internationalAirtimeRepositoryProvider = Provider<InternationalAirtimeRepository>((ref) {
  return InternationalAirtimeRepository(ref.read(apiClientProvider));
});

class InternationalCountriesNotifier extends StateNotifier<DataState<InternationalCountry>> {
  final InternationalAirtimeRepository _repository;

  InternationalCountriesNotifier(this._repository) : super(DataState<InternationalCountry>.initial());

  Future<void> fetchCountries() async {
    state = state.copyWith(isInitialLoading: true, isOverlayHidden: true, message: null);
    try {
      final countries = await _repository.getCountries();
      state = state.copyWith(
        data: countries,
        isDataAvailable: true,
      );
    } catch (e, stack) {
      log('[InternationalCountriesNotifier fetchCountries] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}



class InternationalAirtimePlanNotifier extends StateNotifier<DataState<InternationalAirtimePlan>> {
  final InternationalAirtimeRepository _repository;

  InternationalAirtimePlanNotifier(this._repository) : super(DataState<InternationalAirtimePlan>.initial());

  Future<void> getPlan(String phone) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final plan = await _repository.getPlan(phone);
      state = state.copyWith(
        data: [plan],
        isDataAvailable: true,
      );
    } catch (e, stack) {
      log('[InternationalAirtimePlanNotifier getPlan] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

class InternationalFxRateNotifier extends StateNotifier<DataState<InternationalFxRate>> {
  final InternationalAirtimeRepository _repository;

  InternationalFxRateNotifier(this._repository) : super(DataState<InternationalFxRate>.initial());

  Future<void> getFxRate(double amount, String fromCurrency, int operatorId) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final rate = await _repository.getFxRate(amount, fromCurrency, operatorId);
      state = state.copyWith(
        data: [rate],
        isDataAvailable: true,
      );
    } catch (e, stack) {
      log('[InternationalFxRateNotifier getFxRate] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

class InternationalPurchaseNotifier extends StateNotifier<DataState<InternationalAirtimePurchaseResponse>> {
  final InternationalAirtimeRepository _repository;

  InternationalPurchaseNotifier(this._repository) : super(DataState<InternationalAirtimePurchaseResponse>.initial());

  Future<void> purchase(InternationalAirtimePurchaseRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final response = await _repository.purchase(request);
      state = state.copyWith(
        data: [response],
        isDataAvailable: true,
        message: response.message,
      );
    } catch (e, stack) {
      log('[InternationalPurchaseNotifier purchase] $e\n$stack');
      state = state.copyWith(
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

final internationalCountriesProvider = StateNotifierProvider<InternationalCountriesNotifier, DataState<InternationalCountry>>((ref) {
  return InternationalCountriesNotifier(ref.read(internationalAirtimeRepositoryProvider));
});



final internationalAirtimePlanProvider = StateNotifierProvider<InternationalAirtimePlanNotifier, DataState<InternationalAirtimePlan>>((ref) {
  return InternationalAirtimePlanNotifier(ref.read(internationalAirtimeRepositoryProvider));
});

final internationalFxRateProvider = StateNotifierProvider<InternationalFxRateNotifier, DataState<InternationalFxRate>>((ref) {
  return InternationalFxRateNotifier(ref.read(internationalAirtimeRepositoryProvider));
});

final internationalAirtimePurchaseProvider = StateNotifierProvider<InternationalPurchaseNotifier, DataState<InternationalAirtimePurchaseResponse>>((ref) {
  return InternationalPurchaseNotifier(ref.read(internationalAirtimeRepositoryProvider));
});

final selectedCountryIsoProvider = StateProvider<String>((ref) => '');
final selectedOperatorIdProvider = StateProvider<int>((ref) => 0);
final selectedCurrencyProvider = StateProvider<String>((ref) => 'USD'); // Default to USD? Or detected
