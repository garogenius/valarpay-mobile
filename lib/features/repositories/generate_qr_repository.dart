import 'package:dio/dio.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/generate_qr_response.dart';

class GenerateQrRepository {
  final ApiClient apiClient;

  GenerateQrRepository(this.apiClient);

  /// Generate a payment QR for the provided amount. Backend expects amount as query param.
  Future<GenerateQrResponse> generate({required double amount}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.generateQRCode,
        queryParameters: {'amount': amount.toString()},
      );

      return GenerateQrResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to generate QR code');
    }
  }
}
