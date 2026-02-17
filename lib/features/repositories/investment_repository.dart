import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/models/investment_models.dart';

class InvestmentRepository {
  final ApiClient apiClient;

  InvestmentRepository(this.apiClient);

  Future<InvestmentProduct> getProductInfo() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getInvestmentProduct);
      return InvestmentProduct.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch investment product information');
    }
  }

  Future<CreateInvestmentResponse> createInvestment(CreateInvestmentRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.investments,
        data: request.toJson(),
      );
      return CreateInvestmentResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create investment');
    }
  }

  Future<List<Investment>> getUserInvestments({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await apiClient.get(
        ApiEndpoints.investments,
        queryParameters: queryParams,
      );
      final List data = response.data['data'];
      return data.map((e) => Investment.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch user investments');
    }
  }

  Future<Investment> getInvestmentDetails(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.getInvestmentDetails(id));
      return Investment.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch investment details');
    }
  }
}
