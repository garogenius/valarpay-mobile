import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/api_response.dart';
import 'package:valarpay/features/models/bvn_verification_request.dart';
import 'package:valarpay/features/repositories/wallet_repository.dart';
import 'package:valarpay/core/network/api_client.dart';

class WalletNotifier extends StateNotifier<DataState<ApiResponse>> {
  final WalletRepository _repository;

  WalletNotifier(this._repository) : super(DataState<ApiResponse>.initial());



  /// Create multi-currency account
  Future<void> createMultiCurrencyAccount({
    required String currency,
    required String label,
    String? phoneNumber,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? bvn,
    String? utilityBillPath,
    String? incomeBand,
    String? sourceOfIncome,
    String? accountDesignation,
    String? occupation,
    String? employmentStatus,
    String? additionalIdType,
    String? additionalIdNumber,
    String? additionalIdIssueDate,
    String? additionalIdExpiryDate,
    String? additionalIdDocumentPath,
  }) async {
    this.state = this.state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.createMultiCurrencyAccount(
        currency: currency,
        label: label,
        phoneNumber: phoneNumber,
        address: address,
        city: city,
        state: state,
        postalCode: postalCode,
        bvn: bvn,
        utilityBillPath: utilityBillPath,
        incomeBand: incomeBand,
        sourceOfIncome: sourceOfIncome,
        accountDesignation: accountDesignation,
        occupation: occupation,
        employmentStatus: employmentStatus,
        additionalIdType: additionalIdType,
        additionalIdNumber: additionalIdNumber,
        additionalIdIssueDate: additionalIdIssueDate,
        additionalIdExpiryDate: additionalIdExpiryDate,
        additionalIdDocumentPath: additionalIdDocumentPath,
      );
      this.state = this.state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        data: [res],
        message: res.message,
      );
    } catch (e, stack) {
      log('[WalletNotifier] create account error: $e\n$stack');
      this.state = this.state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
      rethrow;
    }
  }

  Future<bool> openNgnAccount({
    required String docType,
    required String docNumber,
    required String selfieImage,
    required List<String> livenessImages,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.openNgnAccount(
        docType: docType,
        docNumber: docNumber,
        selfieImage: selfieImage,
        livenessImages: livenessImages,
      );
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        data: [res],
        message: res.message,
      );
      return true;
    } catch (e, stack) {
      log('[WalletNotifier openNgnAccount] error: $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
      return false;
    }
  }

  Future<Map<String, dynamic>?> getNgnVirtualAccount() async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getNgnVirtualAccount();
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
      );
      return res;
    } catch (e, stack) {
      log('[WalletNotifier getNgnVirtualAccount] error: $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
      return null;
    }
  }



  void reset() => state = DataState<ApiResponse>.initial();
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return WalletRepository(api);
});

final walletNotifierProvider =
StateNotifierProvider<WalletNotifier, DataState<ApiResponse>>((ref) {
  final repo = ref.read(walletRepositoryProvider);
  return WalletNotifier(repo);
});
