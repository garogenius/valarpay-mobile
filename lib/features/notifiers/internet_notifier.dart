import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/internet_models.dart';
import 'package:valarpay/features/repositories/internet_repository.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

class InternetPlansNotifier extends StateNotifier<DataState<InternetPlanInfo>> {
  final InternetRepository _repository;

  InternetPlansNotifier(this._repository)
    : super(DataState<InternetPlanInfo>.initial());

  Future<void> getPlans({required String currency}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getInternetPlans(currency: currency);
      state = state.copyWith(
        isInitialLoading: false,
        data: res.data,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[InternetPlansNotifier getPlans Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load plans: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<InternetPlanInfo>.initial();
}

class InternetVariationNotifier
    extends StateNotifier<DataState<InternetVariationInfo>> {
  final InternetRepository _repository;

  InternetVariationNotifier(this._repository)
    : super(DataState<InternetVariationInfo>.initial());

  Future<void> getVariations({required String billerCode}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getInternetVariation(
        billerCode: billerCode,
      );
      state = state.copyWith(
        isInitialLoading: false,
        data: res.data,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[InternetVariationNotifier getVariations Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load variations: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<InternetVariationInfo>.initial();
}

class InternetPaymentNotifier
    extends StateNotifier<DataState<InternetPaymentResponse>> {
  final InternetRepository _repository;

  InternetPaymentNotifier(this._repository)
    : super(DataState<InternetPaymentResponse>.initial());

  Future<void> payInternet(InternetPayRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.payInternet(request);
      state = state.copyWith(
        isInitialLoading: false,
        data: [res],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[InternetPaymentNotifier payInternet Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Payment failed: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<InternetPaymentResponse>.initial();
}

// Providers
final internetRepositoryProvider = Provider(
  (ref) => InternetRepository(ref.read(apiClientProvider)),
);

final internetPlansNotifierProvider =
    StateNotifierProvider<InternetPlansNotifier, DataState<InternetPlanInfo>>(
      (ref) => InternetPlansNotifier(ref.read(internetRepositoryProvider)),
    );

final internetVariationNotifierProvider = StateNotifierProvider<
  InternetVariationNotifier,
  DataState<InternetVariationInfo>
>((ref) => InternetVariationNotifier(ref.read(internetRepositoryProvider)));

final internetPaymentNotifierProvider = StateNotifierProvider<
  InternetPaymentNotifier,
  DataState<InternetPaymentResponse>
>((ref) => InternetPaymentNotifier(ref.read(internetRepositoryProvider)));

// UI State Providers
final internetSelectedProviderProvider = StateProvider<InternetPlanInfo?>(
  (ref) => null,
);
final internetSelectedPlanProvider = StateProvider<String?>((ref) => null);

// Internet Beneficiary Notifier
class InternetBeneficiaryNotifier
    extends StateNotifier<DataState<InternetBeneficiary>> {
  final InternetRepository _repository;

  InternetBeneficiaryNotifier(this._repository)
    : super(DataState<InternetBeneficiary>.initial());

  Future<void> getInternetBeneficiaries() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getInternetBeneficiaries();

      if (res.data.isEmpty) {
        state = state.copyWith(
          isInitialLoading: false,
          data: [],
          isDataAvailable: true,
          message: null,
        );
      } else {
        state = state.copyWith(
          isInitialLoading: false,
          data: res.data,
          isDataAvailable: true,
          message: res.message,
        );
      }
    } catch (e, stack) {
      log('[InternetBeneficiaryNotifier getInternetBeneficiaries] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'No saved beneficiaries yet',
      );
    }
  }

  void reset() => state = DataState<InternetBeneficiary>.initial();
}

final internetBeneficiaryNotifierProvider = StateNotifierProvider<
  InternetBeneficiaryNotifier,
  DataState<InternetBeneficiary>
>((ref) => InternetBeneficiaryNotifier(ref.read(internetRepositoryProvider)));
