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
    String? phone,
    String? currency,
    String? category,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getDataPlan,
        query: {
          if (phone != null) 'phone': phone, 
          if (currency != null) 'currency': currency,
          if (category != null) 'category': category,
        },
      );
      return DataPlanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch data plan',
      );
    }
  }

  /// Get data plans for a specific network
  /// Note: PalmPay API doesn't support category filtering - filter client-side by validityDate
  Future<DataVariationResponse> getDataPlansByNetwork({
    String? network,
    int? operatorId,
    String? billerId,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getDataVariation,
        query: {
          if (billerId != null) 'billerId': billerId,
          // PalmPay doesn't use these but keeping for potential fallback
          if (network != null) 'network': network.toLowerCase(),
          if (operatorId != null && operatorId > 0)
            'operatorId': operatorId.toString(),
        },
      );
      return DataVariationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to fetch data plans for $network',
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
        query: {'category': 'BILL', 'billType': 'DATA'},
      );

      return DataBeneficiariesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch data beneficiaries',
      );
    }
  }
}
