import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/transfer_models.dart';
import '../../../core/network/api_client.dart';

class TransferRepository {
  final ApiClient apiClient;

  TransferRepository(this.apiClient);

  Future<BanksResponse> getBanks({required String currency}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getBanksByCurrency(currency),
      );
      return BanksResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data!['message'] ?? 'Failed to get banks');
    }
  }

  Future<BankMatchResponse> getMatchedBanks({
    required String accountNumber,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiEndpoints.getMatchedBanks}/$accountNumber',
      );
      return BankMatchResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to match banks');
    }
  }

  Future<TransferFeeResponse> getTransferFee({
    required String currency,
    required double amount,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getTransferFee,
        queryParameters: {'currency': currency, 'amount': amount},
      );
      return TransferFeeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get transfer fee',
      );
    }
  }

  Future<AccountVerificationResponse> verifyAccount(
    VerifyAccountRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyBankAccount,
        data: request.toJson(),
      );
      return AccountVerificationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to verify account',
      );
    }
  }

  Future<TransferResponse> initiateBankTransfer(
    InitiateTransferRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.initiateBankTransfer,
        data: request.toJson(),
      );
      return TransferResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.response?.data['error'] ??
          e.response?.data['errors']?.toString() ??
          'Transfer processing failed';
      throw Exception(message);
    }
  }

  Future<TransferResponse> initiateNattyPayTransfer(
    InitiateTransferRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.initiateNattyPayTransfer,
        data: request.toJson(),
      );
      return TransferResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.response?.data['error'] ??
          e.response?.data['errors']?.toString() ??
          'Transfer processing failed';
      throw Exception(message);
    }
  }

  Future<TransactionsResponse> getTransactions({
    int? page,
    int? limit,
    String? type,
    String? category,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (page != null) query['page'] = page;
      if (limit != null) query['limit'] = limit;
      if (type != null) query['type'] = type;
      if (category != null) query['category'] = category;

      final response = await apiClient.get(
        ApiEndpoints.getTransactions,
        queryParameters: query,
      );
      return TransactionsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get transactions',
      );
    }
  }

  Future<QRCodeResponse> generateQRCode({required double amount}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.generateQRCode,
        queryParameters: {'amount': amount},
      );
      return QRCodeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to generate QR code',
      );
    }
  }

  Future<DecodeQRCodeResponse> decodeQRCode(DecodeQRCodeRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.decodeQRCode,
        data: request.toJson(),
      );
      return DecodeQRCodeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to decode QR code',
      );
    }
  }
}
