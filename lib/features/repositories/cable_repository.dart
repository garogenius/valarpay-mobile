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
        ApiEndpoints.getCablePlan,
        queryParameters: {'currency': currency},
      );
      return CablePlanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get plans');
    }
  }

  Future<CableVariationResponse> getCableVariation({
    required String billerCode,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getCableVariation,
        queryParameters: {'billerCode': billerCode},
      );
      return CableVariationResponse.fromJson(response.data);
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
        ApiEndpoints.verifyCableNumber,
        data: request.toJson(),
      );

      if (response.data != null && response.data is Map<String, dynamic>) {
        return VerifyCableResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      // If API returned non-map data, return response without typed data
      return VerifyCableResponse(
        data: null,
        message: response.statusMessage ?? 'Verification completed',
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Verification failed');
    }
  }

  Future<CablePaymentResponse> payCable(CablePayRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.payCable,
        data: request.toJson(),
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
