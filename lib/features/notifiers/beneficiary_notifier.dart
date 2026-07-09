import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/beneficiary_models.dart';
import 'package:valarpay/features/repositories/beneficiary_repository.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart'
    show userNotifierProvider;

class BeneficiaryNotifier extends StateNotifier<DataState<Beneficiary>> {
  final BeneficiaryRepository _repository;
  final Ref _ref;

  BeneficiaryNotifier(this._repository, this._ref)
    : super(DataState<Beneficiary>.initial());

  Future<void> getBeneficiaries({
    required String category,
    String? transferType,
    String? billType,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final response = await _repository.getBeneficiaries(
        category: category,
        transferType: transferType,
        billType: billType,
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

  Future<bool> addBeneficiary(Map<String, dynamic> data) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      await _repository.addBeneficiary(data);
      state = state.copyWith(
        isInitialLoading: false,
        message: 'Beneficiary added successfully',
      );
      return true;
    } catch (e, stack) {
      log('[BeneficiaryNotifier addBeneficiary Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        message: 'Failed to add beneficiary: ${e.toString()}',
      );
      return false;
    }
  }

  Future<Beneficiary?> getBeneficiary(String id) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getBeneficiary(id);
      state = state.copyWith(
        isInitialLoading: false,
      );
      return res.data;
    } catch (e, stack) {
      log('[BeneficiaryNotifier getBeneficiary Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        message: 'Failed to get beneficiary: ${e.toString()}',
      );
      return null;
    }
  }

  Future<bool> deleteBeneficiary(String id) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      await _repository.deleteBeneficiary(id);
      state = state.copyWith(
        isInitialLoading: false,
        message: 'Beneficiary deleted successfully',
      );
      return true;
    } catch (e, stack) {
      log('[BeneficiaryNotifier deleteBeneficiary Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        message: 'Failed to delete beneficiary: ${e.toString()}',
      );
      return false;
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
