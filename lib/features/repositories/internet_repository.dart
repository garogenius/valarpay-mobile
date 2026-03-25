import 'package:dio/dio.dart';
import 'package:valarpay/features/models/internet_models.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';

class InternetRepository {
  final ApiClient apiClient;

  InternetRepository(this.apiClient);

  Future<InternetPlanResponse> getInternetPlans({
    required String currency,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getFlutterwaveBillers('INTSERVICE'),
        queryParameters: {'country': 'NG'},
      );
      final dynamic rawData = response.data['data'];
      List data = [];
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map) {
        data = rawData['billers'] ?? rawData['content'] ?? [];
      }
      return InternetPlanResponse(
        data: data.map((json) => InternetPlanInfo.fromJson(json)).toList(),
        message: response.data['message'] ?? 'Success',
        statusCode: response.data['statusCode'] ?? 200,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get internet plans',
      );
    }
  }

  Future<InternetVariationResponse> getInternetVariation({
    required String billerCode,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getFlutterwaveBillInfo,
        queryParameters: {
          'billerCode': billerCode,
          'billType': 'internet',
        },
      );
      final dynamic rawData = response.data['data'];
      List data = [];
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map) {
        data = rawData['products'] ?? rawData['items'] ?? rawData['content'] ?? [];
      }
      return InternetVariationResponse(
        data: data.map((json) => InternetVariationInfo.fromJson(json)).toList(),
        message: response.data['message'] ?? 'Success',
        statusCode: response.data['statusCode'] ?? 200,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get internet variations',
      );
    }
  }

  Future<InternetPaymentResponse> payInternet(
    InternetPayRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.payFlutterwaveBill('internet'),
        data: {
          ...request.toJson(),
          'addBeneficiary': request.addBeneficiary ?? false,
        },
      );
      if (response.data != null && response.data is Map<String, dynamic>) {
        return InternetPaymentResponse.fromJson(response.data);
      }
      return InternetPaymentResponse(
        message: 'Payment initiated',
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Payment failed');
    }
  }

  Future<InternetBeneficiariesResponse> getInternetBeneficiaries() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getBeneficiaries,
        queryParameters: {'category': 'BILL', 'billType': 'INTERNET'},
      );

      return InternetBeneficiariesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load internet beneficiaries',
      );
    }
  }
}
