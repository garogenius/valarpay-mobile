import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:valarpay/features/models/cable_models.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';

class CableRepository {
  final ApiClient apiClient;

  CableRepository(this.apiClient);

  Future<CablePlanResponse> getCablePlans({required String currency}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getFlutterwaveBillers('CABLEBILLS'),
        queryParameters: {'country': 'NG'},
      );
      final dynamic rawData = response.data['data'];
      List data = [];
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map) {
        data = rawData['billers'] ?? rawData['content'] ?? [];
      }
      return CablePlanResponse(
        data: data.map((json) => CablePlanInfo.fromJson(json)).toList(),
        message: response.data['message'] ?? 'Success',
        statusCode: response.data['statusCode'] ?? 200,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get plans');
    }
  }

  Future<CableVariationResponse> getCableVariation({
    required String billerCode,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getFlutterwaveBillInfo,
        queryParameters: {
          'billerCode': billerCode,
          'billType': 'cable',
        },
      );
      final dynamic rawData = response.data['data'];
      List data = [];
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map) {
        data = rawData['products'] ?? rawData['items'] ?? rawData['content'] ?? [];
      }
      return CableVariationResponse(
        data: data.map((json) => CableVariationInfo.fromJson(json)).toList(),
        message: response.data['message'] ?? 'Success',
        statusCode: response.data['statusCode'] ?? 200,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get variations',
      );
    }
  }

  Future<VerifyCableResponse> verifyCableNumber(
    VerifyCableRequest request,
   ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyFlutterwaveCable,
        data: {
          'itemCode': request.billPaymentProductId,
          'billerCode': request.billerCode,
          'billerNumber': request.customerId,
        },
      );
      return VerifyCableResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Verification failed');
    }
  }

  Future<CablePaymentResponse> payCable(CablePayRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.payFlutterwaveBill('cable'),
        data: {
          ...request.toJson(),
          'addBeneficiary': false,
        },
      );
      if (response.data != null && response.data is Map<String, dynamic>) {
        return CablePaymentResponse.fromJson(response.data);
      }
      return CablePaymentResponse(
        message: 'Payment initiated',
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Payment failed');
    }
  }

  Future<CableBeneficiariesResponse> getCableBeneficiaries() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getBeneficiaries,
        queryParameters: {'category': 'BILL', 'billType': 'CABLE'},
      );
      return CableBeneficiariesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get beneficiaries',
      );
    }
  }
}
