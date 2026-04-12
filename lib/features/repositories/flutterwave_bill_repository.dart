import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/models/flutterwave_bill_models.dart';

class FlutterwaveBillRepository {
  final ApiClient apiClient;

  FlutterwaveBillRepository(this.apiClient);

  Future<FlutterwaveBillerResponse> getBillers(String categoryCode, {String country = 'NG'}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getFlutterwaveBillers(categoryCode),
        queryParameters: {'country': country},
      );
      return FlutterwaveBillerResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch billers');
    }
  }

  Future<FlutterwaveCategoryResponse> getCategories() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getFlutterwaveCategories);
      return FlutterwaveCategoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch categories');
    }
  }

  Future<FlutterwaveProductResponse> getBillerProducts(String billerCode, String category, {String? billType}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getFlutterwaveBillInfo,
        queryParameters: {
          'billerCode': billerCode,
          'billType': _mapCategoryToBillType(billType ?? category),
        },
        options: Options(
          headers: {
            'x-api-key': ApiClient.apiKey,
          },
        ),
      );
      return FlutterwaveProductResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch products');
    }
  }

  String _mapCategoryToBillType(String category) {
    final String normalized = category.trim().toUpperCase();
    switch (normalized) {
      case 'SCHPB':
      case 'SCHOOL':
      case 'SCHOOLFEES':
      case 'SCHOOLFEE':
        return 'schoolfee';
      case 'TRANSLOG':
      case 'TRANSPORT':
      case 'TRANSPORTATION':
        return 'transport';
      case 'INTSERVICE':
      case 'INTERNET':
        return 'internet';
      case 'MOBILEDATA':
      case 'DATA':
        return 'internet'; // Based on server list, 'data' might need to be 'internet'
      case 'UTILITYBILLS':
      case 'ELECTRICITY':
        return 'electricity';
      case 'CABLEBILLS':
      case 'CABLE':
      case 'TV':
        return 'cable';
      case 'TAX':
      case 'TAXES':
        return 'tax';
      case 'GOVT':
      case 'GOVTFEES':
      case 'GOVERNMENT_COLLECTIONS':
      case 'GOVERNMENT':
        return 'govt_fees';
      case 'WATER':
        return 'water';
      case 'WAEC':
        return 'waec';
      case 'JAMB':
        return 'jamb';
      case 'AIRTIME':
        return 'airtime';
      default:
        // Try to see if the input itself is one of the valid short codes
        final lower = normalized.toLowerCase();
        final validTypes = [
          'cable', 'electricity', 'internet', 'transport', 'schoolfee', 
          'tax', 'govt_fees', 'water', 'waec', 'jamb', 'airtime'
        ];
        if (validTypes.contains(lower)) return lower;
        return lower;
    }
  }

  Future<FlutterwaveCustomerValidation> validateCustomer({
    required String billPaymentProductId,
    required String customerId,
    required String billerCode,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.validateFlutterwaveCustomer,
        data: {
          'itemCode': billPaymentProductId,
          'billerCode': billerCode,
          'billerNumber': customerId,
        },
      );
      return FlutterwaveCustomerValidation.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Customer validation failed');
    }
  }

  Future<FlutterwavePaymentResponse> payBill(FlutterwavePaymentRequest request) async {
    try {
      final String mappedCategory = _mapCategoryToBillType(request.category);
      final response = await apiClient.post(
        ApiEndpoints.payFlutterwaveBill(mappedCategory),
        data: request.toJson(),
      );
      return FlutterwavePaymentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Payment failed');
    }
  }
}
