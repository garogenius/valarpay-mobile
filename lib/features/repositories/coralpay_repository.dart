import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/models/coralpay_models.dart';

class CoralPayRepository {
  final ApiClient apiClient;

  CoralPayRepository(this.apiClient);

  Future<List<CoralPayGroup>> getGroups() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getCoralPayGroups);
      // log('CoralPay Groups Response: ${response.data}');
      final List data = response.data['data'] ?? [];
      return data.map((json) => CoralPayGroup.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch biller groups');
    }
  }

  Future<List<CoralPayBiller>> getBillers(String groupSlug) async {
    try {
      final response = await apiClient.get(ApiEndpoints.getCoralPayBillers(groupSlug));
      final List data = response.data['data'] ?? [];
      return data.map((json) => CoralPayBiller.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch billers');
    }
  }

  Future<List<CoralPayPackage>> getPackages(String billerSlug) async {
    try {
      final response = await apiClient.get(ApiEndpoints.getCoralPayPackages(billerSlug));
      final List data = response.data['data'] ?? response.data['packages'] ?? [];
      return data.map((json) => CoralPayPackage.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch packages');
    }
  }

  Future<CoralPayCustomerVerification> verifyCustomer({
    required String customerId,
    required String billerSlug,
    required String productName,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyCoralPayCustomer,
        data: {
          'customerId': customerId,
          'billerSlug': billerSlug,
          'productName': productName,
        },
      );
      return CoralPayCustomerVerification.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Customer verification failed');
    }
  }

  Future<CoralPayPaymentResponse> payBill(CoralPayPaymentRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.payCoralPayBill,
        data: request.toJson(),
      );
      return CoralPayPaymentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Bill payment failed');
    }
  }

  Future<List<CoralPayBiller>> getPopularBillers() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getPopularCoralPayBillers);
      final List data = response.data['data'] ?? [];
      return data.map((json) => CoralPayBiller.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch popular billers');
    }
  }
}
