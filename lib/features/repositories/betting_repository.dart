import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/betting_models.dart';
import '../../../core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bettingRepositoryProvider = Provider<BettingRepository>((ref) {
  return BettingRepository(ref.read(apiClientProvider));
});

class BettingRepository {
  final ApiClient apiClient;

  BettingRepository(this.apiClient);

  /// Get available betting platforms
  Future<List<BettingPlatformModel>> getBettingPlatforms() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getBettingPlatforms);
      final List<dynamic> data = response.data['data'];
      return data.map((e) => BettingPlatformModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch betting platforms',
      );
    }
  }

  /// Fund betting platform
  Future<BettingPayResponse> payBetting(BettingPayRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.payBetting,
        data: request.toJson(),
      );
      return BettingPayResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Betting platform funding failed',
      );
    }
  }
}
