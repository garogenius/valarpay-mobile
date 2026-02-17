import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/models/savings_models.dart';

class SavingsRepository {
  final ApiClient apiClient;

  SavingsRepository(this.apiClient);

  Future<List<SavingsProduct>> getSavingsProducts() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getSavingsProducts);
      final List data = response.data['data'];
      return data.map((e) => SavingsProduct.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch savings products');
    }
  }

  Future<SavingsPlan> createSavingsPlan(CreateSavingsPlanRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.savingsPlans,
        data: request.toJson(),
      );
      return SavingsPlan.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create savings plan');
    }
  }

  Future<List<SavingsPlan>> getUserSavingsPlans() async {
    try {
      final response = await apiClient.get(ApiEndpoints.savingsPlans);
      final List data = response.data['data'];
      return data.map((e) => SavingsPlan.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch user savings plans');
    }
  }

  Future<SavingsPlan> getSavingsPlanDetails(String planId) async {
    try {
      final response = await apiClient.get(ApiEndpoints.getSavingsPlanDetails(planId));
      return SavingsPlan.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch savings plan details');
    }
  }

  Future<void> fundSavingsPlan(FundSavingsPlanRequest request) async {
    try {
      await apiClient.post(
        ApiEndpoints.fundSavingsPlan,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fund savings plan');
    }
  }

  Future<void> withdrawSavingsPlan(String planId) async {
    try {
      await apiClient.post(ApiEndpoints.withdrawSavingsPlan(planId));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to withdraw from savings plan');
    }
  }
}
