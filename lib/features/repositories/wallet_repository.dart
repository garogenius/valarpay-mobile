import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/bvn_verification_request.dart';
import 'package:valarpay/features/models/transactions_response.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/models/api_response.dart';

class WalletRepository {
  final ApiClient apiClient;

  WalletRepository(this.apiClient);

  Future<ApiResponse> verifyKyc(BvnVerificationRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.basicKyc,
        data: request.toJson(),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Identity verification failed');
    } catch (e) {
      throw Exception('Unexpected error during identity verification: $e');
    }
  }

  Future<ApiResponse> submitBiometricKyc({
    required String selfieImage,
    required List<String> livenessImages,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.biometricKyc,
        data: {
          "selfieImage": selfieImage,
          "livenessImages": livenessImages,
        },
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Biometric KYC failed');
    }
  }

  Future<ApiResponse> submitSmartSelfieAuth({
    required String selfieImage,
    required List<String> livenessImages,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.smartSelfieAuth,
        data: {
          "selfieImage": selfieImage,
          "livenessImages": livenessImages,
        },
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Smart Selfie Auth failed');
    }
  }

  Future<Map<String, dynamic>> checkSmileIdJobStatus(String jobId) async {
    try {
      final response = await apiClient.get(ApiEndpoints.smileIdJobStatus(jobId));
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to poll job status');
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
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
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
        queryParameters: {'amount': amount.toString(), 'transferType': transferType},
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

  /// Convert currency (Eversend Exchange API integration)
  Future<Map<String, dynamic>> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.convertCurrency,
        data: {
          'from': fromCurrency,
          'to': toCurrency,
          'amount': amount,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to convert currency',
      );
    }
  }

  /// Get exchange rate
  Future<Map<String, dynamic>> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getCurrencyRates,
        queryParameters: {
          'from': fromCurrency,
          'to': toCurrency,
        },
        useAuth: false,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get exchange rate',
      );
    }
  }

  /// Get supported currencies
  Future<Map<String, dynamic>> getSupportedCurrencies() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getSupportedCurrencies,
        useAuth: false,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get supported currencies',
      );
    }
  }

  /// 🏦 Create multi-currency account
  Future<ApiResponse> createMultiCurrencyAccount({
    required String currency,
    required String label,
  }) async {
    try {
      final isPayazaCurrency = currency != 'NGN' &&
          currency != 'USD' &&
          currency != 'GBP';

      final endpoint = isPayazaCurrency
          ? ApiEndpoints.payazaVirtualAccounts
          : ApiEndpoints.createCurrencyAccount;

      final Map<String, dynamic> requestData = {
        'currency': currency,
      };

      if (!isPayazaCurrency) {
        requestData['label'] = label;
      }

      if (isPayazaCurrency) {
        requestData['isPermanent'] = true;
      }

      final response = await apiClient.post(
        endpoint,
        data: requestData,
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create multi-currency account',
      );
    } catch (e) {
      throw Exception('Failed to create multi-currency account: $e');
    }
  }


  /// 🏦 Get Payaza main account(s)
  Future<Map<String, dynamic>> getPayazaMainAccount() async {
    try {
      final response = await apiClient.get(ApiEndpoints.payazaMainAccount);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch main account');
    }
  }

  /// 💳 Verify Payaza account number (name enquiry)
  Future<Map<String, dynamic>> verifyPayazaAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyPayazaAccount,
        data: {'accountNumber': accountNumber, 'bankCode': bankCode},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to verify Payaza account');
    }
  }

  /// 💳 Get Payaza payout status
  Future<Map<String, dynamic>> getPayazaPayoutStatus(String transactionRef) async {
    try {
      final response = await apiClient.get(ApiEndpoints.payazaPayoutStatus(transactionRef));
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get payout status');
    }
  }

  /// 💰 List all Payaza wallets
  Future<Map<String, dynamic>> getPayazaWallets() async {
    try {
      final response = await apiClient.get(ApiEndpoints.payazaWallets);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch Payaza wallets');
    }
  }

  /// 🏦 Get all user multi-currency accounts
  Future<Map<String, dynamic>> getUserAccounts() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getUserAccounts);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch accounts');
    }
  }

  /// 🏦 Get account by currency
  Future<Map<String, dynamic>> getAccountByCurrency(String currency) async {
    try {
      final response = await apiClient.get(ApiEndpoints.getAccountByCurrency(currency));
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch account');
    }
  }

  /// 🏦 Update account label
  Future<Map<String, dynamic>> updateAccountLabel({
    required String currency,
    required String label,
  }) async {
    try {
      final response = await apiClient.patch(
        ApiEndpoints.updateAccount(currency),
        data: {'label': label},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update account');
    }
  }

  /// 🏦 Close auto-currency account
  Future<ApiResponse> closeCurrencyAccount({
    required String currency,
    required String walletPin,
  }) async {
    try {
      final response = await apiClient.delete(
        ApiEndpoints.closeAccount(currency),
        data: {'walletPin': walletPin},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to close account');
    }
  }

  /// 🏦 Get account transactions
  Future<Map<String, dynamic>> getAccountTransactions({
    required String currency,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getAccountTransactions(currency),
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch transactions');
    }
  }

  /// 🏦 Get account deposits
  Future<Map<String, dynamic>> getAccountDeposits({
    required String currency,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getAccountDeposits(currency),
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch deposits');
    }
  }

  /// 🏦 Create mock deposit (Sandbox)
  Future<ApiResponse> createMockDeposit({
    required String currency,
    required double amount,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.createMockDeposit(currency),
        data: {'amount': amount},
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create mock deposit');
    }
  }

  /// 🏦 Create payout destination
  Future<Map<String, dynamic>> createPayoutDestination({
    required String currency,
    required Map<String, dynamic> destinationData,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.createPayoutDestination(currency),
        data: destinationData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create payout destination');
    }
  }

  /// 🏦 Get payout destinations
  Future<Map<String, dynamic>> getPayoutDestinations(String currency) async {
    try {
      final response = await apiClient.get(ApiEndpoints.getPayoutDestinations(currency));
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch payout destinations');
    }
  }

  /// 🏦 Create payout
  Future<ApiResponse> createPayout({
    required String currency,
    required String destinationId,
    required double amount,
    String? description,
  }) async {
    try {
      final isPayazaCurrency = currency != 'NGN' &&
          currency != 'USD' &&
          currency != 'GBP';

      final endpoint = isPayazaCurrency
          ? ApiEndpoints.createPayazaPayout
          : ApiEndpoints.createPayout(currency);

      final payload = isPayazaCurrency
          ? {
              'sourceWalletId': destinationId,
              'amount': amount,
              'currency': currency,
              'reason': description ?? 'Exchange Payout',
            }
          : {
              'destination_id': destinationId,
              'amount': amount,
              if (description != null) 'description': description,
            };

      final response = await apiClient.post(
        endpoint,
        data: payload,
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create payout');
    }
  }

  /// 🏦 Get payouts
  Future<Map<String, dynamic>> getPayouts({
    required String currency,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getPayouts(currency),
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch payouts');
    }
  }
}
