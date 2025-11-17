import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/transfer_models.dart';
import 'package:valarpay/features/repositories/transfer_repository.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

/// Repository provider
final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepository(ref.read(apiClientProvider));
});

/// Banks Notifier
class BanksNotifier extends StateNotifier<DataState<BanksResponse>> {
  final TransferRepository _repository;

  BanksNotifier(this._repository) : super(DataState<BanksResponse>.initial());

  Future<void> fetchBanks({required String currency}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getBanks(currency: currency);
      state = state.copyWith(
        isInitialLoading: false,
        singleData: res,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[BanksNotifier fetchBanks] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load banks: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<BanksResponse>.initial();
}

class BankMatchNotifier extends StateNotifier<DataState<BankMatchResponse>> {
  final TransferRepository _repository;

  BankMatchNotifier(this._repository)
    : super(DataState<BankMatchResponse>.initial());

  Future<void> fetchMatchedBanks({required String accountNumber}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getMatchedBanks(
        accountNumber: accountNumber,
      );
      state = state.copyWith(
        isInitialLoading: false,
        singleData: res,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[BanksNotifier fetchMatchedBanks] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load banks: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<BankMatchResponse>.initial();
}

/// Transfer Fee Notifier
class TransferFeeNotifier extends StateNotifier<DataState<TransferFee>> {
  final TransferRepository _repository;

  TransferFeeNotifier(this._repository)
    : super(DataState<TransferFee>.initial());

  Future<void> getTransferFee({
    required String currency,
    required double amount,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getTransferFee(
        currency: currency,
        amount: amount,
      );
      state = state.copyWith(
        isInitialLoading: false,
        data: [res.data],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[TransferFeeNotifier getTransferFee] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to get transfer fee: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<TransferFee>.initial();
}

/// Account Verification Notifier
class AccountVerificationNotifier
    extends StateNotifier<DataState<AccountDetails>> {
  final TransferRepository _repository;

  AccountVerificationNotifier(this._repository)
    : super(DataState<AccountDetails>.initial());

  Future<void> verifyAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final request = VerifyAccountRequest(
        accountNumber: accountNumber,
        bankCode: bankCode,
      );
      final res = await _repository.verifyAccount(request);
      state = state.copyWith(
        isInitialLoading: false,
        data: [res.data],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[AccountVerificationNotifier verifyAccount] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to verify account: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<AccountDetails>.initial();
}

/// Transfer Notifier
class TransferNotifier extends StateNotifier<DataState<TransferResponse>> {
  final TransferRepository _repository;

  TransferNotifier(this._repository)
    : super(DataState<TransferResponse>.initial());

  Future<void> initiateTransfer({
    required String bankCode,
    required String accountNumber,
    required double amount,
    required String currency,
    required String description,
    required String pin,
    required bool saveBeneficiary,
    required String sessionId,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final request = InitiateTransferRequest(
        bankCode: bankCode,
        accountNumber: accountNumber,
        amount: amount,
        currency: currency,
        description: description,
        pin: pin,
        saveBeneficiary: saveBeneficiary,
        sessionId: sessionId,
      );

      final res = await _repository.initiateTransfer(request);

      state = state.copyWith(
        isInitialLoading: false,
        data: [res],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[TransferNotifier initiateTransfer] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Transfer failed: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<TransferResponse>.initial();
}

/// Transactions Notifier
class TransactionsNotifier extends StateNotifier<DataState<Transaction>> {
  final TransferRepository _repository;

  TransactionsNotifier(this._repository)
    : super(DataState<Transaction>.initial());

  Future<void> fetchTransactions({
    int? page,
    int? limit,
    String? type,
    String? category,
  }) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.getTransactions(
        page: page,
        limit: limit,
        type: type,
        category: category,
      );
      state = state.copyWith(
        isInitialLoading: false,
        data: res.transactions,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[TransactionsNotifier fetchTransactions] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to load transactions: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<Transaction>.initial();
}

/// QR Code Notifier
class QRCodeNotifier extends StateNotifier<DataState<QRCodeResponse>> {
  final TransferRepository _repository;

  QRCodeNotifier(this._repository) : super(DataState<QRCodeResponse>.initial());

  Future<void> generateQRCode({required double amount}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.generateQRCode(amount: amount);
      state = state.copyWith(
        isInitialLoading: false,
        data: [res],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[QRCodeNotifier generateQRCode] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to generate QR code: ${e.toString()}',
      );
    }
  }

  Future<void> decodeQRCode({required String qrCode}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final request = DecodeQRCodeRequest(qrCode: qrCode);
      final res = await _repository.decodeQRCode(request);
      // Store decoded data in a different way since it's QRCodeData, not QRCodeResponse
      // You might want to create a separate notifier for decoded QR data
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[QRCodeNotifier decodeQRCode] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to decode QR code: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<QRCodeResponse>.initial();
}

/// QR Code Data Notifier (for decoded QR codes)
class QRCodeDataNotifier extends StateNotifier<DataState<QRCodeData>> {
  final TransferRepository _repository;

  QRCodeDataNotifier(this._repository) : super(DataState<QRCodeData>.initial());

  Future<void> decodeQRCode({required String qrCode}) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final request = DecodeQRCodeRequest(qrCode: qrCode);
      final res = await _repository.decodeQRCode(request);
      state = state.copyWith(
        isInitialLoading: false,
        data: [res.data],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[QRCodeDataNotifier decodeQRCode] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: 'Failed to decode QR code: ${e.toString()}',
      );
    }
  }

  void reset() => state = DataState<QRCodeData>.initial();
}

// Riverpod providers
final banksNotifierProvider =
    StateNotifierProvider<BanksNotifier, DataState<BanksResponse>>(
      (ref) => BanksNotifier(ref.read(transferRepositoryProvider)),
    );

final bankMatchNotifierProvider =
    StateNotifierProvider<BankMatchNotifier, DataState<BankMatchResponse>>(
      (ref) => BankMatchNotifier(ref.read(transferRepositoryProvider)),
    );

final transferFeeNotifierProvider =
    StateNotifierProvider<TransferFeeNotifier, DataState<TransferFee>>(
      (ref) => TransferFeeNotifier(ref.read(transferRepositoryProvider)),
    );

final accountVerificationNotifierProvider = StateNotifierProvider<
  AccountVerificationNotifier,
  DataState<AccountDetails>
>((ref) => AccountVerificationNotifier(ref.read(transferRepositoryProvider)));

final beneficiaryAccountVerificationNotifierProvider = StateNotifierProvider<
  AccountVerificationNotifier,
  DataState<AccountDetails>
>((ref) => AccountVerificationNotifier(ref.read(transferRepositoryProvider)));

final internalAccountVerificationNotifierProvider = StateNotifierProvider<
  AccountVerificationNotifier,
  DataState<AccountDetails>
>((ref) => AccountVerificationNotifier(ref.read(transferRepositoryProvider)));

final transferNotifierProvider =
    StateNotifierProvider<TransferNotifier, DataState<TransferResponse>>(
      (ref) => TransferNotifier(ref.read(transferRepositoryProvider)),
    );

final transactionsNotifierProvider =
    StateNotifierProvider<TransactionsNotifier, DataState<Transaction>>(
      (ref) => TransactionsNotifier(ref.read(transferRepositoryProvider)),
    );

final qrCodeNotifierProvider =
    StateNotifierProvider<QRCodeNotifier, DataState<QRCodeResponse>>(
      (ref) => QRCodeNotifier(ref.read(transferRepositoryProvider)),
    );

final qrCodeDataNotifierProvider =
    StateNotifierProvider<QRCodeDataNotifier, DataState<QRCodeData>>(
      (ref) => QRCodeDataNotifier(ref.read(transferRepositoryProvider)),
    );
