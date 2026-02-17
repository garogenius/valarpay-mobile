import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/beneficiary_models.dart';
import 'package:valarpay/core/network/api_client.dart';

class BeneficiaryRepository {
  final ApiClient apiClient;

  BeneficiaryRepository(this.apiClient);

  Future<BeneficiariesResponse> getBeneficiaries({
    required String category,
    String? transferType,
    String? billType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'category': category,
      };

      if (transferType != null && transferType.isNotEmpty) {
        queryParams['transferType'] = transferType;
      }

      if (billType != null && billType.isNotEmpty) {
        queryParams['billType'] = billType;
      }

      final response = await apiClient.get(
        ApiEndpoints.getBeneficiaries,
        queryParameters: queryParams,
      );

      return BeneficiariesResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
