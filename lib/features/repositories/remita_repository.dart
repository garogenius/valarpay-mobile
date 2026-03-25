import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/models/remita_models.dart';

class RemitaRepository {
  final ApiClient apiClient;

  RemitaRepository(this.apiClient);

  Future<List<RemitaCategory>> getCategories({int page = 0, int size = 20}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getRemitaCategories,
        query: {'page': page, 'size': size},
      );
      final dynamic rawData = response.data['data'] ?? response.data['categories'];
      List data = [];
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map) {
        data = rawData['categories'] ?? rawData['content'] ?? rawData['items'] ?? [];
      } else if (response.data['categories'] is List) {
        data = response.data['categories'];
      }
      return data.map((json) => RemitaCategory.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch categories');
    }
  }

  Future<List<RemitaBiller>> getBillersByCategory(String categoryId, {int page = 0, int size = 20}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getRemitaPlan(categoryId),
        query: {'page': page, 'size': size},
      );
      final dynamic rawData = response.data['data'] ?? response.data['billers'];
      List data = [];
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map) {
        data = rawData['billers'] ?? rawData['content'] ?? rawData['items'] ?? [];
      } else if (response.data['billers'] is List) {
        data = response.data['billers'];
      }
      return data.map((json) => RemitaBiller.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch billers');
    }
  }

  Future<List<RemitaProduct>> getBillerProducts(String billerId, {int page = 0, int size = 20}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getRemitaBillerProducts(billerId),
        query: {'page': page, 'size': size},
      );
      final dynamic rawData = response.data['data'] ?? response.data['products'] ?? response.data['items'];
      List data = [];
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map) {
        data = rawData['products'] ?? rawData['content'] ?? rawData['items'] ?? [];
      } else if (response.data['products'] is List) {
        data = response.data['products'];
      } else if (response.data['items'] is List) {
        data = response.data['items'];
      }
      return data.map((json) => RemitaProduct.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch products');
    }
  }

  Future<RemitaCustomerValidation> validateCustomer({
    required String billPaymentProductId,
    required String customerId,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.validateRemitaCustomer,
        data: {
          'billPaymentProductId': billPaymentProductId,
          'customerId': customerId,
        },
      );
      return RemitaCustomerValidation.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Customer validation failed');
    }
  }

  Future<RemitaInitiationResponse> initiatePayment(RemitaInitiateRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.initiateRemitaPayment,
        data: request.toJson(),
      );
      return RemitaInitiationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Payment initiation failed');
    }
  }

  Future<RemitaPaymentResponse> payBill(RemitaPaymentRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.payRemitaBill,
        data: request.toJson(),
      );
      return RemitaPaymentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Payment failed');
    }
  }

  Future<List<RemitaProduct>> getVendingProducts({
    int page = 0,
    int pageSize = 20,
    String countryCode = 'NGA',
    String? categoryCode,
    String? provider,
  }) async {
    try {
      final query = {
        'page': page,
        'pageSize': pageSize,
        'countryCode': countryCode,
      };
      if (categoryCode != null) query['categoryCode'] = categoryCode;
      if (provider != null) query['provider'] = provider.toLowerCase();

      final response = await apiClient.get(
        ApiEndpoints.getRemitaVendingProducts,
        query: query,
      );
      final dynamic rawData = response.data['data'] ?? response.data['products'] ?? response.data['items'];
      List data = [];
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map) {
        data = rawData['products'] ?? rawData['content'] ?? rawData['items'] ?? [];
      } else if (response.data['products'] is List) {
        data = response.data['products'];
      } else if (response.data['items'] is List) {
        data = response.data['items'];
      }
      return data.map((json) => RemitaProduct.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch vending products');
    }
  }
}
