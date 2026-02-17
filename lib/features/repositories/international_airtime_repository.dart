import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/models/international_airtime_models.dart';

class InternationalAirtimeRepository {
  final ApiClient apiClient;

  InternationalAirtimeRepository(this.apiClient);

  Future<List<InternationalCountry>> getCountries() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getInternationalCountries);
      final List data = response.data['data'] ?? [];
      return data.map((json) => InternationalCountry.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch countries');
    }
  }



  Future<InternationalAirtimePlan> getPlan(String phone) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getInternationalPlan,
        query: {'phone': phone},
      );
      return InternationalAirtimePlan.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch plan');
    }
  }

  Future<InternationalFxRate> getFxRate(double amount, String fromCurrency, int operatorId) async {
    // 1. If NGN, no conversion needed
    if (fromCurrency.toUpperCase() == 'NGN') {
      return InternationalFxRate(
        rate: 1.0,
        amount: amount,
        convertedAmount: amount,
        fromCurrency: 'NGN',
        toCurrency: 'NGN',
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
        // New v1 API returns flat response, not wrapped in 'data'
        final data = Map<String, dynamic>.from(response.data);
        return InternationalFxRate.fromJson(data);
      } catch (e) {
         // If convert-currency fails, we could fallback, but based on user directive 
         // we should only use it for these 3.
      }
    }

    // 3. Others use the "fix rate logic" (original FX rate endpoint)
    try {
      final response = await apiClient.get(
        ApiEndpoints.getInternationalFxRate,
        query: {
          'amount': amount.toString(),
          'operatorId': operatorId.toString(),
        },
      );
      final data = Map<String, dynamic>.from(response.data['data']);
      if (data['amount'] == null) data['amount'] = amount;
      return InternationalFxRate.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch FX rate');
    }
  }

  Future<InternationalAirtimePurchaseResponse> purchase(
    InternationalAirtimePurchaseRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.payInternationalAirtime,
        data: request.toJson(),
      );
      return InternationalAirtimePurchaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Purchase failed');
    }
  }

  Future<InternationalAirtimeBalance> getBalance() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getInternationalBalance);
      return InternationalAirtimeBalance.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch balance');
    }
  }
}
