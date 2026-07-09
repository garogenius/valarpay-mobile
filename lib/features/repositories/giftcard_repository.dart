import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/giftcard.dart';
import '../../../core/network/api_client.dart';

class GiftCardRepository {
  final ApiClient apiClient;

  GiftCardRepository(this.apiClient);

  Future<List<GiftCardCategory>> getCategories() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getGiftCardCategories);
      final List<dynamic> data = response.data;
      return data.map((item) => GiftCardCategory.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get categories',
      );
    }
  }

  Future<GiftCardProductResponse> getProducts({
    required String currency,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getGiftCardProducts,
        queryParameters: {'currency': currency},
      );
      if (response.data is List) {
        return GiftCardProductResponse.fromJson({'data': response.data});
      }
      if (response.data is Map) {
        return GiftCardProductResponse.fromJson(Map<String, dynamic>.from(response.data));
      }
      return GiftCardProductResponse.fromJson({});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get products');
    }
  }

  Future<void> payForGiftCard(GiftCardPaymentRequest request) async {
    try {
      await apiClient.post(ApiEndpoints.payGiftCard, data: request.toJson());
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Payment failed');
    }
  }

  Future<GiftCardRedeemCodeResponse> getRedeemCode({
    required String transactionId,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getGiftCardRedeemCode,
        queryParameters: {'transactionId': transactionId},
      );
      return GiftCardRedeemCodeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get redeem code',
      );
    }
  }

  Future<GiftCardFxRateResponse> getFxRate({
    required String currency,
    required double amount,
  }) async {
    // 1. If USD, no conversion needed
    if (currency.toUpperCase() == 'USD') {
      return GiftCardFxRateResponse(
        message: 'Success',
        statusCode: 200,
        data: GiftCardFxRateData(
          senderCurrency: 'USD',
          senderAmount: amount,
          recipientCurrency: 'USD',
          recipientAmount: amount,
        ),
      );
    }

    // 2. Only USD, GBP, EUR, and NGN use the convert-currency endpoint
    const convertSupported = ['USD', 'GBP', 'EUR', 'NGN'];
    if (convertSupported.contains(currency.toUpperCase())) {
      try {
        final response = await apiClient.post(
          ApiEndpoints.convertCurrency,
          data: {
            'amount': amount,
            'fromCurrency': currency,
            'toCurrency': 'USD',
          },
          useAuth: false,
        );
        
        // New v1 API returns flat response
        final rawData = response.data;
        if (rawData != null) {
          // The UI expects the USD amount in senderAmount
          return GiftCardFxRateResponse(
            message: 'Success',
            statusCode: 200,
            data: GiftCardFxRateData(
              senderCurrency: 'USD',
              senderAmount: (rawData['convertedAmount'] ?? 0).toDouble(),
              recipientCurrency: rawData['fromCurrency'] ?? currency,
              recipientAmount: (rawData['amount'] ?? amount).toDouble(),
            ),
          );
        }
      } catch (e) {
        // Fallthrough to original endpoint if convert-currency fails
      }
    }

    // 3. Others use the "fix rate logic" (the original giftcard FX rate endpoint)
    try {
      final response = await apiClient.get(
        ApiEndpoints.getGiftCardFxRate,
        queryParameters: {'currency': currency, 'amount': amount},
      );
      return GiftCardFxRateResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch FX rate');
    }
  }

  Future<GiftcardBeneficiariesResponse> getGiftcardBeneficiaries() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getBeneficiaries,
        queryParameters: {'category': 'BILL', 'billType': 'GIFTCARD'},
      );
      return GiftcardBeneficiariesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get beneficiaries',
      );
    }
  }

  /// Check status of a gift card purchase
  Future<Map<String, dynamic>> checkGiftCardStatus(String billRef) async {
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
}
