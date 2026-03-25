class NetworkProvider {
  final String id;
  final String planName;
  final String network;
  final String countryISOCode;
  final int operatorId;
  final String? billerId;
  final String? billerIcon;
  final DateTime createdAt;
  final DateTime updatedAt;

  NetworkProvider({
    required this.id,
    required this.planName,
    required this.network,
    required this.countryISOCode,
    required this.operatorId,
    this.billerId,
    this.billerIcon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NetworkProvider.fromJson(Map<String, dynamic> json) =>
      NetworkProvider(
        id: json['id']?.toString() ?? json['operatorId']?.toString() ?? json['billerId']?.toString() ?? '',
        planName: json['name'] ?? json['planName'] ?? json['billerName'] ?? json['biller_name'] ?? json['short_name'] ?? '',
        network: json['network'] ?? json['code'] ?? json['name'] ?? json['billerName'] ?? json['biller_name'] ?? json['short_name'] ?? '',
        countryISOCode: json['countryISOCode'] ?? (json['country'] is Map ? json['country']['isoName'] : null) ?? '',
        operatorId: json['operatorId'] ?? 0,
        billerId: json['billerId']?.toString() ?? json['code']?.toString() ?? json['biller_code']?.toString(),
        billerIcon: json['billerIcon']?.toString() ?? json['logoUrl']?.toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'planName': planName,
        'network': network,
        'countryISOCode': countryISOCode,
        'operatorId': operatorId,
        'billerId': billerId,
        'billerIcon': billerIcon,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class NetworkProvidersResponse {
  final List<NetworkProvider> providers;
  final String message;
  final int statusCode;

  NetworkProvidersResponse({
    required this.providers,
    required this.message,
    required this.statusCode,
  });

  factory NetworkProvidersResponse.fromJson(Map<String, dynamic> json) {
    List<NetworkProvider> providersList = [];
    final dynamic dataJson = json['data'] ?? json['billers'];

    if (dataJson != null && dataJson is List) {
      providersList = (dataJson)
          .map((provider) => NetworkProvider.fromJson(provider))
          .toList();
    } else if (dataJson != null && dataJson is Map) {
      final list = dataJson['operators'] ?? dataJson['billers'] ?? dataJson['content'] ?? dataJson['items'] ?? [];
      if (list is List) {
        providersList = list
            .map((provider) => NetworkProvider.fromJson(provider))
            .toList();
      }
    } else if (json['operators'] != null && json['operators'] is List) {
      providersList = (json['operators'] as List)
          .map((provider) => NetworkProvider.fromJson(provider))
          .toList();
    } else if (json['billers'] != null && json['billers'] is List) {
      providersList = (json['billers'] as List)
          .map((provider) => NetworkProvider.fromJson(provider))
          .toList();
    }

    return NetworkProvidersResponse(
      providers: providersList,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
    );
  }
}
