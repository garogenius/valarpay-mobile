import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/models/flutterwave_bill_models.dart';

class FlutterwaveBillRepository {
  final ApiClient apiClient;

  FlutterwaveBillRepository(this.apiClient);

  Future<FlutterwaveBillerResponse> getBillers(String categoryCode, {String country = 'NG'}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getFlutterwaveBillers(categoryCode),
        queryParameters: {'country': country},
      );
      return FlutterwaveBillerResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch billers');
    }
  }

  Future<FlutterwaveCategoryResponse> getCategories() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getFlutterwaveCategories);
      return FlutterwaveCategoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch categories');
    }
  }

  Future<FlutterwaveProductResponse> getBillerProducts(String billerCode, String category) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getFlutterwaveBillInfo,
        queryParameters: {
          'billerCode': billerCode,
          'billType': category.toLowerCase(),
        },
      );
      return FlutterwaveProductResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch products');
    }
  }

  Future<FlutterwaveCustomerValidation> validateCustomer({
    required String billPaymentProductId,
    required String customerId,
    required String billerCode,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.validateFlutterwaveCustomer,
        data: {
          'itemCode': billPaymentProductId,
          'billerCode': billerCode,
          'billerNumber': customerId,
        },
      );
      return FlutterwaveCustomerValidation.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Customer validation failed');
    }
  }

  Future<FlutterwavePaymentResponse> payBill(FlutterwavePaymentRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.payFlutterwaveBill(request.category.toLowerCase()),
        data: request.toJson(),
      );
      return FlutterwavePaymentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Payment failed');
    }
  }
}
