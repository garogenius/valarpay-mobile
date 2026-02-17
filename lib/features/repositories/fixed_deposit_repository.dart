import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/models/fixed_deposit_models.dart';

class FixedDepositRepository {
  final ApiClient apiClient;

  FixedDepositRepository(this.apiClient);

  Future<List<FixedDepositPlan>> getAvailablePlans() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getFixedDepositPlans);
      final List data = response.data['data'];
      return data.map((e) => FixedDepositPlan.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch fixed deposit plans');
    }
  }

  Future<FixedDeposit> createFixedDeposit(CreateFixedDepositRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.fixedDeposits,
        data: request.toJson(),
      );
      return FixedDeposit.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create fixed deposit');
    }
  }

  Future<List<FixedDeposit>> getUserDeposits() async {
    try {
      final response = await apiClient.get(ApiEndpoints.fixedDeposits);
      final List data = response.data['data'];
      return data.map((e) => FixedDeposit.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch fixed deposits');
    }
  }

  Future<void> earlyWithdrawal(String depositId) async {
    try {
      await apiClient.post(
        ApiEndpoints.earlyWithdrawFixedDeposit,
        data: {'depositId': depositId},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed early withdrawal');
    }
  }

  Future<void> maturityPayout(String depositId) async {
    try {
      await apiClient.post(ApiEndpoints.payoutFixedDeposit(depositId));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed maturity payout');
    }
  }
}
