import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/electricity.dart';
import '../../../core/network/api_client.dart';

class ElectricityRepository {
  final ApiClient apiClient;

  ElectricityRepository(this.apiClient);

  Future<void> fetchFlutterwaveCategories() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getFlutterwaveCategories);
      // log('Flutterwave Bill Categories: ${response.data}');
    } catch (e) {
      log('Error fetching Flutterwave Categories: $e');
    }
  }

  Future<ElectricityPlanResponse> getElectricityPlans({
    required String currency,
  }) async {
    try {
      // First fetch categories to console as requested
      await fetchFlutterwaveCategories();

      final response = await apiClient.get(
        ApiEndpoints.getFlutterwaveBillers('UTILITYBILLS'),
        queryParameters: {'country': 'NG'},
      );
      final dynamic rawData = response.data['data'];
      List data = [];
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map) {
        data = rawData['billers'] ?? rawData['content'] ?? [];
      }
      return ElectricityPlanResponse(
        data: data.map((json) => ElectricityPlan.fromJson(json)).toList(),
        message: response.data['message'] ?? 'Success',
        statusCode: response.data['statusCode'] ?? 200,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get electricity plans',
      );
    }
  }

  Future<ElectricityBillInfoResponse> getBillInfo({
    required String billerId,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getFlutterwaveBillInfo,
        queryParameters: {
          'billerCode': billerId,
          'billType': 'electricity',
        },
      );
      final dynamic rawData = response.data['data'];
      List data = [];
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map) {
        data = rawData['products'] ?? rawData['items'] ?? rawData['content'] ?? [];
      }
      return ElectricityBillInfoResponse(
        data: data.map((json) => ElectricityBillInfo.fromJson(json)).toList(),
        message: response.data['message'] ?? 'Success',
        statusCode: response.data['statusCode'] ?? 200,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get bill information',
      );
    }
  }

  Future<VerifyMeterNumberResponse> verifyMeterNumber(
    VerifyMeterNumberRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyFlutterwaveElectricity,
        data: {
          'itemCode': request.billPaymentProductId,
          'billerCode': request.billerCode,
          'billerNumber': request.customerId,
        },
      );
      return VerifyMeterNumberResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Invalid meter number');
    }
  }

  Future<ElectricityPaymentResponse> payElectricity(
    ElectricityPaymentRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.payFlutterwaveBill('electricity'),
        data: {
          ...request.toJson(),
          'addBeneficiary': false,
        },
      );
      return ElectricityPaymentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Payment failed');
    }
  }


  Future<ElectricityBeneficiariesResponse> getElectricityBeneficiaries({
    required String userId,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getBeneficiaries,
        queryParameters: {'category': 'BILL', 'billType': 'ELECTRICITY'},
      );

      return ElectricityBeneficiariesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to fetch electricity beneficiaries',
      );
    }
  }
}
