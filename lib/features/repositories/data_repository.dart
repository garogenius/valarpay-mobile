import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/network_provider.dart';
import 'package:valarpay/features/models/data_models.dart';
import '../../../core/network/api_client.dart';

class DataRepository {
  final ApiClient apiClient;

  DataRepository(this.apiClient);

  /// Get available network providers for data
  /// Uses airtime network providers endpoint since data providers endpoint doesn't exist
  Future<NetworkProvidersResponse> getDataNetworkProviders() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getAirtimeNetworkProviders,
      );
      return NetworkProvidersResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch data network providers',
      );
    }
  }

  /// Get data plan for a phone number
  Future<DataPlanResponse> getDataPlan({
    required String phone,
    required String currency,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getDataPlan,
        query: {'phone': phone, 'currency': currency},
      );
      return DataPlanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch data plan',
      );
    }
  }

  /// Get data variation by operator ID
  Future<DataVariationResponse> getDataVariation({
    required int operatorId,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getDataVariation,
        query: {'operatorId': operatorId.toString()},
      );
      return DataVariationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch data variation',
      );
    }
  }

  /// Purchase data
  Future<DataPurchaseResponse> payData(DataPurchaseRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.purchaseData,
        data: request.toJson(),
      );
      return DataPurchaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Data purchase failed');
    }
  }

  /// Get saved data beneficiaries
  Future<DataBeneficiariesResponse> getDataBeneficiaries({
    required String userId,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getUserBeneficiaries,
        query: {'transferType': 'TRANSFER', 'billType': 'data'},
      );

      return DataBeneficiariesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch data beneficiaries',
      );
    }
  }
}
