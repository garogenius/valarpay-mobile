import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/models/education_models.dart';

class EducationRepository {
  final ApiClient apiClient;

  EducationRepository(this.apiClient);

  Future<List<EducationBiller>> getSchoolBillers() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getSchoolBillers);
      final List data = response.data['data'] ?? [];
      return data.map((json) => EducationBiller.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch school billers');
    }
  }

  Future<List<EducationBiller>> getRemitaSchoolBillers() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getRemitaSchoolBillers);
      final List data = response.data['data'] ?? [];
      return data.map((json) => EducationBiller.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch Remita school billers');
    }
  }

  Future<List<EducationBiller>> getVendingProviders() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getVendingProviders);
      final List data = response.data['data'] ?? [];
      return data.map((json) => EducationBiller.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch vending providers');
    }
  }

  Future<List<EducationProduct>> getEducationBillerItems(String billerCode) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getEducationBillerItems,
        query: {'billerCode': billerCode},
      );
      final List data = response.data['data'] ?? [];
      return data.map((json) => EducationProduct.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch biller items');
    }
  }

  Future<List<EducationProduct>> getVendingProducts({
    required String provider,
    String categoryCode = 'educations',
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getVendingProducts,
        query: {
          'categoryCode': categoryCode,
          'provider': provider.toLowerCase(),
        },
      );
      final List data = response.data['data'] ?? [];
      return data.map((json) => EducationProduct.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch vending products');
    }
  }

  Future<EducationVerificationResponse> verifySchoolCustomer({
    required String itemCode,
    required String billerCode,
    required String billerNumber,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifySchoolCustomer,
        data: {
          'itemCode': itemCode,
          'billerCode': billerCode,
          'billerNumber': billerNumber,
        },
      );
      return EducationVerificationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Verification failed');
    }
  }

  Future<EducationVerificationResponse> verifyWaecBillerNumber({
    required String itemCode,
    required String billerNumber,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyWaecBillerNumber,
        data: {
          'itemCode': itemCode,
          'billerCode': 'WAEC',
          'billerNumber': billerNumber,
        },
      );
      return EducationVerificationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'WAEC verification failed');
    }
  }

  Future<EducationVerificationResponse> verifyJambBillerNumber({
    required String itemCode,
    required String billerNumber,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.verifyJambBillerNumber,
        data: {
          'itemCode': itemCode,
          'billerCode': 'JAMB',
          'billerNumber': billerNumber,
        },
      );
      return EducationVerificationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'JAMB verification failed');
    }
  }

  Future<EducationPaymentResponse> paySchoolFees(EducationPaymentRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.paySchoolFees,
        data: request.toJson(),
      );
      return EducationPaymentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'School fee payment failed');
    }
  }

  Future<EducationPaymentResponse> payWaec(EducationPaymentRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.payWaec,
        data: request.toJson(),
      );
      return EducationPaymentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'WAEC payment failed');
    }
  }

  Future<EducationPaymentResponse> payJamb(EducationPaymentRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.payJamb,
        data: request.toJson(),
      );
      return EducationPaymentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'JAMB payment failed');
    }
  }
}
