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
        query: {'currency': currency},
      );
      return GiftCardProductResponse.fromJson(response.data);
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
        query: {'transactionId': transactionId},
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
    try {
      final response = await apiClient.get(
        ApiEndpoints.getGiftCardFxRate,
        query: {'currency': currency, 'amount': amount},
      );
      return GiftCardFxRateResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get FX rate');
    }
  }

  Future<GiftcardBeneficiariesResponse> getGiftcardBeneficiaries() async {
    try {
      final response = await apiClient.get(
        '/api/v1/user/get-beneficiaries',
        query: {'transferType': 'TRANSFER', 'billType': 'giftcard'},
      );
      return GiftcardBeneficiariesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get beneficiaries',
      );
    }
  }
}
