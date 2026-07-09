import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/bvn_verification_request.dart';
import 'package:valarpay/features/models/transactions_response.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/models/api_response.dart';

class WalletRepository {
  final ApiClient apiClient;

  WalletRepository(this.apiClient);


  Future<ApiResponse> openNgnAccount({
    required String docType,
    required String docNumber,
    required String selfieImage,
    required List<String> livenessImages,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.openNgnAccount,
        data: {
          'docType': docType,
          'docNumber': docNumber,
          'selfieImage': selfieImage,
          'livenessImages': livenessImages,
        },
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to open NGN account');
    }
  }

  Future<Map<String, dynamic>> getNgnVirtualAccount() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getNgnAccount);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch NGN virtual account');
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

  /// 📜 Check bill purchase status
  Future<Map<String, dynamic>> checkBillStatus({
    required String billRef,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.getBillStatus,
        data: {'billRef': billRef},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to check bill status',
      );
    }
  }

  /// 📜 Check gift card purchase status
  Future<Map<String, dynamic>> checkGiftCardStatus({
    required String billRef,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.getGiftCardStatus,
        data: {'billRef': billRef},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to check gift card status',
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

  /// Get multi-currency fee
  Future<Map<String, dynamic>> getMultiCurrencyFees({
    required String currency,
    required double amount,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getMultiCurrencyFees,
        queryParameters: {'currency': currency, 'amount': amount.toString()},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch multi-currency fees',
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
    required String userId,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.convertCurrency,
        data: {
          'from': fromCurrency,
          'to': toCurrency,
          'amount': amount,
          'userId': userId,
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
    try {
      final isPayshiga = currency == 'USD' || currency == 'EUR' || currency == 'GBP';
      final isPayaza = currency != 'NGN' && !isPayshiga;

      if (isPayshiga) {
        if (utilityBillPath == null) {
          throw Exception('Utility bill is required for $currency account creation.');
        }

        final formDataMap = <String, dynamic>{
          'currency': currency,
          if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
          if (address != null && address.isNotEmpty) 'address': address,
          if (city != null && city.isNotEmpty) 'city': city,
          if (state != null && state.isNotEmpty) 'state': state,
          if (postalCode != null && postalCode.isNotEmpty) 'postalCode': postalCode,
          if (bvn != null && bvn.isNotEmpty) 'bvn': bvn,
          if (incomeBand != null) 'incomeBand': incomeBand,
          if (sourceOfIncome != null) 'sourceOfIncome': sourceOfIncome,
          if (accountDesignation != null) 'accountDesignation': accountDesignation,
          if (occupation != null) 'occupation': occupation,
          if (employmentStatus != null) 'employmentStatus': employmentStatus,
          if (additionalIdType != null) 'additionalIdType': additionalIdType,
          if (additionalIdNumber != null) 'additionalIdNumber': additionalIdNumber,
          if (additionalIdIssueDate != null) 'additionalIdIssueDate': additionalIdIssueDate,
          if (additionalIdExpiryDate != null) 'additionalIdExpiryDate': additionalIdExpiryDate,
        };

        if (utilityBillPath != null) {
          formDataMap['utilityBill'] = await MultipartFile.fromFile(utilityBillPath);
        }
        
        if (additionalIdDocumentPath != null) {
          formDataMap['additionalIdDocument'] = await MultipartFile.fromFile(additionalIdDocumentPath);
        }

        final formData = FormData.fromMap(formDataMap);
        final response = await apiClient.postFormData(
          ApiEndpoints.createPayshigaAccount,
          data: formData,
        );
        return ApiResponse.fromJson(response.data);
      } else if (isPayaza) {
        final requestData = {
          'currency': currency,
          'label': label,
        };

        final response = await apiClient.post(
          ApiEndpoints.payazaVirtualAccounts,
          data: requestData,
        );
        return ApiResponse.fromJson(response.data);
      } else {
        // NGN logic
        final requestData = {
          'currency': currency,
          'label': label,
        };

        final response = await apiClient.post(
          ApiEndpoints.createCurrencyAccount,
          data: requestData,
        );
        return ApiResponse.fromJson(response.data);
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create multi-currency account',
      );
    } catch (e) {
      throw Exception('Failed to create multi-currency account: $e');
    }
  }

  /// 🏦 Get Payshiga account status
  Future<Map<String, dynamic>> getPayshigaAccountStatus() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getPayshigaAccountStatus);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch Payshiga account status');
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
    required String currency,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyPayazaAccount,
        data: {'accountNumber': accountNumber, 'bankCode': bankCode, 'currency': currency},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to verify Payaza account');
    }
  }

  /// 🏦 Get Payaza merchant banks
  Future<Map<String, dynamic>> getPayazaMerchantBanks(String currency) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.payazaMerchantBanks(currency),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch merchant banks');
    }
  }

  /// 🏦 Get Payaza virtual account details
  Future<Map<String, dynamic>> getPayazaVirtualAccountDetails(String accountNumber) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.payazaVirtualAccountDetails(accountNumber),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch account details');
    }
  }

  /// 💸 Create Payaza payout
  Future<Map<String, dynamic>> createPayazaPayout({
    required String sourceWalletId,
    required double amount,
    required String currency,
    required String destinationCountry,
    required String accountReference,
    required String bankCode,
    required String accountNumber,
    required String accountName,
    required String transactionType,
    required int transactionPin,
    required String reason,
    required String senderPhone,
    required String senderAddress,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.createPayazaPayout,
        data: {
          'sourceWalletId': sourceWalletId,
          'amount': amount,
          'currency': currency,
          'destinationCountry': destinationCountry,
          'accountReference': accountReference,
          'bankCode': bankCode,
          'accountNumber': accountNumber,
          'accountName': accountName,
          'transactionType': transactionType,
          'transactionPin': transactionPin,
          'reason': reason,
          'senderPhone': senderPhone,
          'senderAddress': senderAddress,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to initiate payout');
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

  /// 💸 Create Payshiga payout
  Future<Map<String, dynamic>> createPayshigaPayout({
    required String sourceWalletId,
    required double amount,
    required String currency,
    required String bankCode,
    required String accountNumber,
    required String accountName,
    required String narration,
    required String reference,
    String? accountType,
    String? bsbNumber,
    String? routingNumber,
  }) async {
    try {
      final Map<String, dynamic> meta = {};
      
      if (accountType != null) {
        meta['accountType'] = accountType;
      }
      if (bsbNumber != null && bsbNumber.isNotEmpty) {
        meta['bsbNumber'] = bsbNumber;
      }
      if (routingNumber != null && routingNumber.isNotEmpty) {
        meta['routingNumber'] = routingNumber;
      }

      final payload = {
        'sourceWallet': sourceWalletId,
        'amount': amount,
        'currency': currency,
        'accountNumber': accountNumber,
        'bankCode': bankCode,
        'bankName': 'N/A', // Payshiga uses bank code
        'accountName': accountName,
        'narration': narration,
        'reference': reference,
        'saveBeneficiary': false,
      };

      if (meta.isNotEmpty) {
        payload['meta'] = meta;
      }

      final response = await apiClient.post(
        ApiEndpoints.createPayshigaPayout,
        data: payload,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to initiate Payshiga payout');
    }
  }

  /// 💳 Get Payshiga payout status
  Future<Map<String, dynamic>> getPayshigaPayoutStatus(String transactionRef) async {
    try {
      final response = await apiClient.get(ApiEndpoints.payshigaPayoutStatus(transactionRef));
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get Payshiga payout status');
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

  Future<Map<String, dynamic>> getPayazaWallet(String walletId) async {
    try {
      final response = await apiClient.get(ApiEndpoints.payazaWalletDetails(walletId));
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch Payaza wallet details');
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
