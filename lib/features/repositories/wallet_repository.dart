import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/bvn_verification_request.dart';
import 'package:valarpay/features/models/transactions_response.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/models/api_response.dart';

class WalletRepository {
  final ApiClient apiClient;

  WalletRepository(this.apiClient);

  Future<ApiResponse> verifyBVN(BvnVerificationRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyBvn,
        data: request.toJson(),
      );
      print(response);
      print(response.data);

      return ApiResponse.fromJson(response.data);

    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'BVN verification failed',
      );
    } catch (e) {
      throw Exception('Unexpected error during bvn verification: $e');
    }
  }

  /// 💳 Get all transactions with optional filters
  Future<TransactionsResponse> getAllTransactions({
    int? page,
    int? limit,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? userId,
    String? type,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (dateFrom != null && dateFrom.isNotEmpty)
        queryParams['dateFrom'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) queryParams['dateTo'] = dateTo;
      if (userId != null && userId.isNotEmpty) queryParams['userId'] = userId;
       if (type != null && type.isNotEmpty) queryParams['type'] = type;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;

      final response = await apiClient.get(
        ApiEndpoints.getTransactions,
        query: queryParams.isNotEmpty ? queryParams : null,
      );

      return TransactionsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch transactions',
      );
    }
  }

  /// 🏦 Get all banks
  Future<Map<String, dynamic>> getBanks() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getBanks);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch banks');
    }
  }

  ///  Get transfer fee
  Future<Map<String, dynamic>> getTransferFee({
    required double amount,
    required String transferType,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getTransferFee,
        query: {'amount': amount.toString(), 'transferType': transferType},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch transfer fee',
      );
    }
  }

  ///  Verify account
  Future<Map<String, dynamic>> verifyAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyAccount,
        data: {'accountNumber': accountNumber, 'bankCode': bankCode},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to verify account',
      );
    }
  }

  /// 💰 Initiate transfer
  Future<Map<String, dynamic>> initiateTransfer({
    required String accountNumber,
    required String bankCode,
    required double amount,
    required String narration,
    required String pin,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.initiateTransfer,
        data: {
          'accountNumber': accountNumber,
          'bankCode': bankCode,
          'amount': amount,
          'narration': narration,
          'pin': pin,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to initiate transfer',
      );
    }
  }
}
