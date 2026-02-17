import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/electricity.dart';
import '../../../core/network/api_client.dart';

class ElectricityRepository {
  final ApiClient apiClient;

  ElectricityRepository(this.apiClient);

  Future<ElectricityPlanResponse> getElectricityPlans({
    required String currency,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getElectricityPlan,
        queryParameters: {'currency': currency},
      );
      return ElectricityPlanResponse.fromJson(response.data);
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
        ApiEndpoints.getElectricityVariation,
        queryParameters: {'billerId': billerId},
      );
      return ElectricityBillInfoResponse.fromJson(response.data);
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
        ApiEndpoints.verifyMeterNumber,
        data: request.toJson(),
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
        ApiEndpoints.payElectricity,
        data: request.toJson(),
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
