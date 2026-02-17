import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/models/easylife_models.dart';

class EasyLifeRepository {
  final ApiClient apiClient;

  EasyLifeRepository(this.apiClient);

  Future<EasyLifeProduct> getProductInfo() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getEasyLifeProduct);
      return EasyLifeProduct.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch product information');
    }
  }

  Future<EasyLifePlan> createPlan(CreateEasyLifePlanRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.easyLifePlans,
        data: request.toJson(),
      );
      return EasyLifePlan.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create EasyLife plan');
    }
  }

  Future<List<EasyLifePlan>> getUserPlans() async {
    try {
      final response = await apiClient.get(ApiEndpoints.easyLifePlans);
      final List data = response.data['data'];
      return data.map((e) => EasyLifePlan.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch user plans');
    }
  }

  Future<EasyLifePlan> getPlanDetails(String planId) async {
    try {
      final response = await apiClient.get(ApiEndpoints.getEasyLifePlanDetails(planId));
      return EasyLifePlan.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch plan details');
    }
  }

  Future<void> fundPlan(FundEasyLifePlanRequest request) async {
    try {
      await apiClient.post(
        ApiEndpoints.fundEasyLifePlan,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fund plan');
    }
  }

  Future<void> withdrawPlan(String planId) async {
    try {
      await apiClient.post(ApiEndpoints.withdrawEasyLifePlan(planId));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to withdraw from plan');
    }
  }
}
