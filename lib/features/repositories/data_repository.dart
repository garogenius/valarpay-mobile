import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/features/models/network_provider.dart';
import 'package:valarpay/features/models/data_models.dart';
import '../../../core/network/api_client.dart';

class DataRepository {
  final ApiClient apiClient;

  DataRepository(this.apiClient);

  /// Get available network providers for data
  Future<NetworkProvidersResponse> getDataNetworkProviders() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getDataNetworkProviders,
      );
      if (response.data is List) {
        return NetworkProvidersResponse(
          providers: (response.data as List).map((p) => NetworkProvider.fromJson(p)).toList(),
          message: 'Success',
          statusCode: 200,
        );
      }
      return NetworkProvidersResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch data network providers',
      );
    }
  }

  /// Get data plan for a phone number
  Future<DataPlanResponse> getDataPlan({
    String? phone,
    String? currency,
    String? category,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getDataPlan,
        query: {
          if (phone != null) 'phone': phone, 
          if (currency != null) 'currency': currency,
          if (category != null) 'category': category,
        },
      );
      return DataPlanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch data plan',
      );
    }
  }

  /// Get data plans for a specific network
  Future<DataVariationResponse> getDataPlansByNetwork({
    String? network,
    int? operatorId,
    String? billerId,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getDataNetworkProviders,
      );

      final rawData = response.data is Map ? (response.data['data'] ?? response.data['billers'] ?? response.data) : response.data;
      List<dynamic> dataList = [];
      if (rawData is List) {
        dataList = rawData;
      } else if (rawData is Map) {
        dataList = rawData["billers"] ?? rawData["data"] ?? [];
      }

      var targetBiller;
      final searchNetwork = (network ?? '').toLowerCase();
      final searchBillerId = (billerId ?? '').toLowerCase();
      
      for (var b in dataList) {
        if (b is Map) {
          final bName = (b['name'] ?? b['billerName'] ?? b['network'] ?? '').toString().toLowerCase();
          final bCode = (b['billerId'] ?? b['code'] ?? '').toString().toLowerCase();
          
          if ((searchBillerId.isNotEmpty && bCode.contains(searchBillerId)) ||
              (searchNetwork.isNotEmpty && bName.contains(searchNetwork)) ||
              (searchNetwork.isNotEmpty && searchNetwork.contains(bName))) {
            targetBiller = b;
            break;
          }
        }
      }

      List<Map<String, dynamic>> plansList = [];
      if (targetBiller != null && targetBiller is Map) {
        final bool isBillItems = targetBiller['billItems'] != null;
        final plans = targetBiller['billItems'] ?? targetBiller['plans'] ?? targetBiller['items'] ?? targetBiller['variations'] ?? [];
        if (plans is List) {
          for (var plan in plans) {
            if (plan is Map) {
              final Map<String, dynamic> planMap = Map<String, dynamic>.from(plan);
              
              planMap['id'] = (planMap['billerItemId'] ?? planMap['itemId'] ?? planMap['id'] ?? planMap['operatorId'] ?? '').toString();
              planMap['name'] = planMap['name'] ?? planMap['description'] ?? planMap['itemName'] ?? '';
              planMap['network'] ??= targetBiller['network'] ?? targetBiller['name'];
              planMap['billerId'] ??= targetBiller['billerId'] ?? targetBiller['code'];
              
              final double amt = double.tryParse(planMap['localAmount']?.toString() ?? planMap['amount']?.toString() ?? '0') ?? 0.0;
              if (isBillItems) {
                planMap['amount'] = amt / 100.0;
                planMap['localAmount'] = amt / 100.0;
              } else {
                planMap['amount'] = amt;
                planMap['localAmount'] = amt;
              }
              plansList.add(planMap);
            }
          }
        }
      }

      return DataVariationResponse.fromJson({
        'data': plansList,
        'message': 'Success',
        'statusCode': 200,
      });
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to fetch data plans for $network',
      );
    }
  }

  /// Purchase data
  Future<DataPurchaseResponse> payData(DataPurchaseRequest request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.purchaseData,
        data: request.toJson(),
      );
      return DataPurchaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Data purchase failed');
    }
  }

  /// Get saved data beneficiaries
  Future<DataBeneficiariesResponse> getDataBeneficiaries({
    required String userId,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getUserBeneficiaries,
        query: {'category': 'BILL', 'billType': 'DATA'},
      );

      return DataBeneficiariesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch data beneficiaries',
      );
    }
  }

  /// Check status of a bill purchase (airtime/data)
  Future<Map<String, dynamic>> checkBillStatus(String billRef) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.getBillStatus,
        data: {'billRef': billRef},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to check bill status',
      );
    }
  }
}
