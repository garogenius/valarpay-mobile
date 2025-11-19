import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/electricity.dart';
import 'package:valarpay/features/repositories/electricity_repository.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

class ElectricityNotifier extends StateNotifier<DataState<ElectricityPlan>> {
  final ElectricityRepository _repository;

  ElectricityNotifier(this._repository)
    : super(DataState<ElectricityPlan>.initial());

  Future<void> getElectricityPlans({required String currency}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final response = await _repository.getElectricityPlans(
        currency: currency,
      );
      state = state.copyWith(
        isInitialLoading: false,
        data: response.data,
        isDataAvailable: true,
        message: response.message,
      );
    } catch (e, stack) {
      log('[ElectricityNotifier getElectricityPlans Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to get electricity plans: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<ElectricityPlan>.initial();
}

class ElectricityBillInfoNotifier
    extends StateNotifier<DataState<ElectricityBillInfo>> {
  final ElectricityRepository _repository;

  ElectricityBillInfoNotifier(this._repository)
    : super(DataState<ElectricityBillInfo>.initial());

  Future<void> getBillInfo({required String billerCode}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final response = await _repository.getBillInfo(billerCode: billerCode);
      state = state.copyWith(
        isInitialLoading: false,
        data: response.data,
        isDataAvailable: true,
        message: response.message,
      );
    } catch (e, stack) {
      log('[ElectricityBillInfoNotifier getBillInfo Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to get bill information: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<ElectricityBillInfo>.initial();
}

class ElectricityPaymentNotifier
    extends StateNotifier<DataState<ElectricityPaymentResponse>> {
  final ElectricityRepository _repository;

  ElectricityPaymentNotifier(this._repository)
    : super(DataState<ElectricityPaymentResponse>.initial());

  Future<VerifyMeterNumberResponse?> verifyMeterNumber(
    VerifyMeterNumberRequest request,
  ) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final response = await _repository.verifyMeterNumber(request);
      state = state.copyWith(
        isInitialLoading: false,
        message: response.message,
      );
      return response;
    } catch (e, stack) {
      log('[ElectricityPaymentNotifier verifyMeterNumber Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
      return null;
    }
  }

  Future<void> payElectricity(ElectricityPaymentRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final response = await _repository.payElectricity(request);

      // Check if the response indicates an error
      if (response.statusCode != 200 && response.statusCode != 201) {
        state = state.copyWith(
          isInitialLoading: false,
          isDataAvailable: false,
          message: response.message,
        );
      } else {
        state = state.copyWith(
          isInitialLoading: false,
          isDataAvailable: true,
          singleData: response,
          message: response.message,
        );
      }
    } catch (e, stack) {
      log('[ElectricityPaymentNotifier payElectricity Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
    }
  }

  void reset() => state = DataState<ElectricityPaymentResponse>.initial();
}

class ElectricityBeneficiaryNotifier
    extends StateNotifier<DataState<ElectricityBeneficiary>> {
  final ElectricityRepository _repository;

  ElectricityBeneficiaryNotifier(this._repository)
    : super(DataState<ElectricityBeneficiary>.initial());

  Future<void> getElectricityBeneficiaries() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final response = await _repository.getElectricityBeneficiaries(
        userId: '',
      );

      final electricityBeneficiaries =
          response.data.where((benef) {
            final billType = benef.billType?.toLowerCase() ?? '';
            final isAirtimeOrData =
                billType.contains('airtime') || billType.contains('data');
            final hasElectricityFields =
                (benef.discoName != null && benef.discoName!.isNotEmpty) ||
                (benef.meterNumber.isNotEmpty) ||
                (benef.meterType != null && benef.meterType!.isNotEmpty);

            return !isAirtimeOrData && hasElectricityFields;
          }).toList();

      state = state.copyWith(
        isInitialLoading: false,
        data: electricityBeneficiaries,
        isDataAvailable: electricityBeneficiaries.isNotEmpty,
        message: electricityBeneficiaries.isEmpty ? null : response.message,
      );
    } catch (e, stack) {
      log(
        '[ElectricityBeneficiaryNotifier getElectricityBeneficiaries] $e\n$stack',
      );
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to get electricity beneficiaries: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<ElectricityBeneficiary>.initial();
}

// Providers
final electricityRepositoryProvider = Provider(
  (ref) => ElectricityRepository(ref.read(apiClientProvider)),
);

final electricityNotifierProvider =
    StateNotifierProvider<ElectricityNotifier, DataState<ElectricityPlan>>(
      (ref) => ElectricityNotifier(ref.read(electricityRepositoryProvider)),
    );

final electricityBillInfoNotifierProvider = StateNotifierProvider<
  ElectricityBillInfoNotifier,
  DataState<ElectricityBillInfo>
>(
  (ref) => ElectricityBillInfoNotifier(ref.read(electricityRepositoryProvider)),
);

final electricityPaymentNotifierProvider = StateNotifierProvider<
  ElectricityPaymentNotifier,
  DataState<ElectricityPaymentResponse>
>((ref) => ElectricityPaymentNotifier(ref.read(electricityRepositoryProvider)));

final electricityBeneficiaryNotifierProvider = StateNotifierProvider<
  ElectricityBeneficiaryNotifier,
  DataState<ElectricityBeneficiary>
>(
  (ref) =>
      ElectricityBeneficiaryNotifier(ref.read(electricityRepositoryProvider)),
);

// UI State Providers
final electricitySelectedDiscoProvider = StateProvider<ElectricityPlan?>(
  (ref) => null,
);

final electricitySelectedMeterTypeProvider =
    StateProvider<ElectricityBillInfo?>((ref) => null);
