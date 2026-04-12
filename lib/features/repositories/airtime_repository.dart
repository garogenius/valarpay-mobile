import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/network_provider.dart';
import 'package:valarpay/features/models/airtime_models.dart';
import '../../../core/network/api_client.dart';

class AirtimeRepository {
  final ApiClient apiClient;

  AirtimeRepository(this.apiClient);

  /// Get available network providers for airtime using PalmPay
  Future<NetworkProvidersResponse> getAirtimeNetworkProviders() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getAirtimeNetworkProviders,
      );
      return NetworkProvidersResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to fetch airtime network providers',
      );
    }
  }

  /// Get airtime plan using phone and currency
  Future<List<AirtimePlan>> getAirtimePlan({
    required String phone,
    required String currency,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getAirtimePlan,
        query: {
          'phone': phone,
          'currency': currency,
        },
      );
      final data = response.data['data'];
      if (data != null && data is List) {
        return data.map((e) => AirtimePlan.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch airtime plan',
      );
    }
  }

  /// Get airtime items by biller ID
  Future<AirtimePlanResponse> getAirtimeVariation({
    required String billerId,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getAirtimeVariation,
        query: {'billerId': billerId},
      );
      return AirtimePlanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch airtime variation',
      );
    }
  }

  /// Purchase airtime
  // Future<AirtimePurchaseResponse> payAirtime(
  //   AirtimePurchaseRequest request,
  // ) async {
  //   try {
  //     final response = await apiClient.post(
  //       ApiEndpoints.payAirtime,
  //       data: request.toJson(),
  //     );
  //     return AirtimePurchaseResponse.fromJson(response.data);
  //   } on DioException catch (e) {
  //     throw Exception(e.response?.data['message'] ?? 'Airtime purchase failed');
  //   }
  // }
  Future<AirtimePurchaseResponse> payAirtime(
    AirtimePurchaseRequest request,
  ) async {
    try {
      final requestData = request.toJson();
      // print('[AirtimeRepository] Purchase request data: $requestData');
      // print(
      //   '[AirtimeRepository] addBeneficiary value: ${request.addBeneficiary}',
      // );

      final response = await apiClient.post(
        ApiEndpoints.payAirtime,
        data: requestData,
      );
      final data = response.data;
      return AirtimePurchaseResponse.fromJson(data);
    } on DioException catch (e) {
      final message =
          (e.response?.data?['message'] ??
                  e.message ??
                  'Airtime purchase failed')
              .toString()
              .replaceAll('Exception: ', '')
              .trim();

      return AirtimePurchaseResponse(
        message: message,
        statusCode: e.response?.statusCode ?? 400,
        success: false,
      );
    } catch (e) {
      return AirtimePurchaseResponse(
        message: 'Unexpected error: ${e.toString()}',
        statusCode: 500,
        success: false,
      );
    }
  }

  /// Get international FX rate
  Future<InternationalFxRateResponse> getInternationalFxRate({
    required double amount,
    required String fromCurrency,
    required int operatorId,
  }) async {
    // 1. If NGN, no conversion needed
    if (fromCurrency.toUpperCase() == 'NGN') {
      return InternationalFxRateResponse(
        message: 'Success',
        statusCode: 200,
        data: InternationalFxRate(
          id: 0,
          name: 'NGN',
          fxRate: 1.0,
          currencyCode: 'NGN',
        ),
      );
    }

    // 2. Only USD, GBP, and EUR use the convert-currency endpoint
    const convertSupported = ['USD', 'GBP', 'EUR'];
    if (convertSupported.contains(fromCurrency.toUpperCase())) {
      try {
        final response = await apiClient.post(
          ApiEndpoints.convertCurrency,
          data: {
            'amount': amount,
            'fromCurrency': fromCurrency,
            'toCurrency': 'NGN',
          },
          useAuth: false,
        );
        final rawData = response.data;
        if (rawData != null) {
          return InternationalFxRateResponse(
            message: response.data['message'] ?? 'Success',
            statusCode: response.data['statusCode'] ?? 200,
            data: InternationalFxRate(
              id: 0,
              name: rawData['fromCurrency'] ?? fromCurrency,
              fxRate: (rawData['rate'] ?? rawData['fxRate'] ?? 0.0).toDouble(),
              currencyCode: rawData['fromCurrency'] ?? fromCurrency,
            ),
          );
        }
        return InternationalFxRateResponse.fromJson(response.data);
      } catch (e) {
        // Fallback or handle error
      }
    }

    // 3. Others use the "fix rate logic" (the original international FX rate endpoint)
    try {
      final response = await apiClient.get(
        ApiEndpoints.getInternationalFxRate,
        query: {
          'amount': amount.toString(),
          'operatorId': operatorId.toString(),
        },
      );
      return InternationalFxRateResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch FX rate');
    }
  }

  /// Get international airtime plan
  Future<AirtimePlanResponse> getInternationalPlan({
    required String phone,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getInternationalPlan,
        query: {'phone': phone},
      );
      return AirtimePlanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch international plan',
      );
    }
  }

  /// Pay for international airtime
  Future<AirtimePurchaseResponse> payInternationalAirtime(
    AirtimePurchaseRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.payInternationalAirtime,
        data: request.toJson(),
      );
      return AirtimePurchaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'International airtime purchase failed',
      );
    }
  }

  /// Get saved airtime beneficiaries
  Future<AirtimeBeneficiariesResponse> getAirtimeBeneficiaries({
    required String userId,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getUserBeneficiaries,
        query: {'category': 'BILL', 'billType': 'AIRTIME'},
      );

      // Debug log the raw response
      // print('[AirtimeRepository] Raw response: ${response.data}');

      return AirtimeBeneficiariesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch airtime beneficiaries',
      );
    }
  }
}
