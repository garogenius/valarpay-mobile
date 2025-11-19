// Data Plan Models
class DataPlan {
  final int id;
  final int operatorId;
  final String name;
  final bool bundle;
  final bool data;
  final bool pin;
  final bool comboProduct;
  final bool supportsLocalAmounts;
  final bool supportsGeographicalRechargePlans;
  final String denominationType;
  final String senderCurrencyCode;
  final String senderCurrencySymbol;
  final String destinationCurrencyCode;
  final String destinationCurrencySymbol;
  final double commission;
  final double internationalDiscount;
  final double localDiscount;
  final double? mostPopularAmount;
  final double? mostPopularLocalAmount;
  final double? minAmount;
  final double? maxAmount;
  final double? localMinAmount;
  final double? localMaxAmount;
  final Country country;
  final FxRate fx;
  final List<String> logoUrls;
  final List<double> fixedAmounts;
  final Map<String, dynamic> fixedAmountsDescriptions;
  final List<double> localFixedAmounts;
  final Map<String, dynamic>? localFixedAmountsDescriptions;
  final List<double> suggestedAmounts;
  final Map<String, dynamic> suggestedAmountsMap;
  final Fees fees;
  final List<dynamic> geographicalRechargePlans;
  final List<dynamic> promotions;
  final String status;

  DataPlan({
    required this.id,
    required this.operatorId,
    required this.name,
    required this.bundle,
    required this.data,
    required this.pin,
    required this.comboProduct,
    required this.supportsLocalAmounts,
    required this.supportsGeographicalRechargePlans,
    required this.denominationType,
    required this.senderCurrencyCode,
    required this.senderCurrencySymbol,
    required this.destinationCurrencyCode,
    required this.destinationCurrencySymbol,
    required this.commission,
    required this.internationalDiscount,
    required this.localDiscount,
    this.mostPopularAmount,
    this.mostPopularLocalAmount,
    this.minAmount,
    this.maxAmount,
    this.localMinAmount,
    this.localMaxAmount,
    required this.country,
    required this.fx,
    required this.logoUrls,
    required this.fixedAmounts,
    required this.fixedAmountsDescriptions,
    required this.localFixedAmounts,
    this.localFixedAmountsDescriptions,
    required this.suggestedAmounts,
    required this.suggestedAmountsMap,
    required this.fees,
    required this.geographicalRechargePlans,
    required this.promotions,
    required this.status,
  });

  factory DataPlan.fromJson(Map<String, dynamic> json) => DataPlan(
    id: json['id'] ?? 0,
    operatorId: json['operatorId'] ?? 0,
    name: json['name'] ?? '',
    bundle: json['bundle'] ?? false,
    data: json['data'] ?? false,
    pin: json['pin'] ?? false,
    comboProduct: json['comboProduct'] ?? false,
    supportsLocalAmounts: json['supportsLocalAmounts'] ?? false,
    supportsGeographicalRechargePlans:
        json['supportsGeographicalRechargePlans'] ?? false,
    denominationType: json['denominationType'] ?? '',
    senderCurrencyCode: json['senderCurrencyCode'] ?? '',
    senderCurrencySymbol: json['senderCurrencySymbol'] ?? '',
    destinationCurrencyCode: json['destinationCurrencyCode'] ?? '',
    destinationCurrencySymbol: json['destinationCurrencySymbol'] ?? '',
    commission: (json['commission'] ?? 0).toDouble(),
    internationalDiscount: (json['internationalDiscount'] ?? 0).toDouble(),
    localDiscount: (json['localDiscount'] ?? 0).toDouble(),
    mostPopularAmount: json['mostPopularAmount']?.toDouble(),
    mostPopularLocalAmount: json['mostPopularLocalAmount']?.toDouble(),
    minAmount: json['minAmount']?.toDouble(),
    maxAmount: json['maxAmount']?.toDouble(),
    localMinAmount: json['localMinAmount']?.toDouble(),
    localMaxAmount: json['localMaxAmount']?.toDouble(),
    country: Country.fromJson(json['country'] ?? {}),
    fx: FxRate.fromJson(json['fx'] ?? {}),
    logoUrls: List<String>.from(json['logoUrls'] ?? []),
    fixedAmounts: List<double>.from(
      (json['fixedAmounts'] ?? []).map((x) => x.toDouble()),
    ),
    fixedAmountsDescriptions: Map<String, dynamic>.from(
      json['fixedAmountsDescriptions'] ?? {},
    ),
    localFixedAmounts: List<double>.from(
      (json['localFixedAmounts'] ?? []).map((x) => x.toDouble()),
    ),
    localFixedAmountsDescriptions:
        json['localFixedAmountsDescriptions'] != null
            ? Map<String, dynamic>.from(json['localFixedAmountsDescriptions'])
            : null,
    suggestedAmounts: List<double>.from(
      (json['suggestedAmounts'] ?? []).map((x) => x.toDouble()),
    ),
    suggestedAmountsMap: Map<String, dynamic>.from(
      json['suggestedAmountsMap'] ?? {},
    ),
    fees: Fees.fromJson(json['fees'] ?? {}),
    geographicalRechargePlans: List<dynamic>.from(
      json['geographicalRechargePlans'] ?? [],
    ),
    promotions: List<dynamic>.from(json['promotions'] ?? []),
    status: json['status'] ?? '',
  );
}

class Country {
  final String isoName;
  final String name;

  Country({required this.isoName, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) =>
      Country(isoName: json['isoName'] ?? '', name: json['name'] ?? '');
}

class FxRate {
  final double rate;
  final String currencyCode;

  FxRate({required this.rate, required this.currencyCode});

  factory FxRate.fromJson(Map<String, dynamic> json) => FxRate(
    rate: (json['rate'] ?? 1).toDouble(),
    currencyCode: json['currencyCode'] ?? '',
  );
}

class Fees {
  final double international;
  final double local;
  final double localPercentage;
  final double internationalPercentage;

  Fees({
    required this.international,
    required this.local,
    required this.localPercentage,
    required this.internationalPercentage,
  });

  factory Fees.fromJson(Map<String, dynamic> json) => Fees(
    international: (json['international'] ?? 0).toDouble(),
    local: (json['local'] ?? 0).toDouble(),
    localPercentage: (json['localPercentage'] ?? 0).toDouble(),
    internationalPercentage: (json['internationalPercentage'] ?? 0).toDouble(),
  );
}

// Data Plan Response with network and plans array
class DataPlanResponse {
  final String? network;
  final List<DataPlanInfo> plans;
  final String message;
  final int statusCode;

  DataPlanResponse({
    this.network,
    required this.plans,
    required this.message,
    required this.statusCode,
  });

  factory DataPlanResponse.fromJson(Map<String, dynamic> json) {
    List<DataPlanInfo> plansList = [];

    if (json['data']?['plan'] != null && json['data']['plan'] is List) {
      plansList =
          (json['data']['plan'] as List)
              .map((plan) => DataPlanInfo.fromJson(plan))
              .toList();
    }

    return DataPlanResponse(
      network: json['data']?['network'],
      plans: plansList,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
    );
  }
}

// Data Plan Info (simplified version from the plan array)
class DataPlanInfo {
  final String id;
  final String network;
  final String planName;
  final String countryISOCode;
  final int operatorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  DataPlanInfo({
    required this.id,
    required this.network,
    required this.planName,
    required this.countryISOCode,
    required this.operatorId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DataPlanInfo.fromJson(Map<String, dynamic> json) => DataPlanInfo(
    id: json['id']?.toString() ?? '',
    network: json['network'] ?? '',
    planName: json['planName'] ?? '',
    countryISOCode: json['countryISOCode'] ?? '',
    operatorId: json['operatorId'] ?? 0,
    createdAt:
        json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
    updatedAt:
        json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now(),
  );
}

// Data Variation Response
class DataVariationResponse {
  final DataPlan data;
  final String message;
  final int statusCode;

  DataVariationResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory DataVariationResponse.fromJson(Map<String, dynamic> json) =>
      DataVariationResponse(
        data: DataPlan.fromJson(json['data'] ?? {}),
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'] ?? 200,
      );
}

// Data Purchase Request
class DataPurchaseRequest {
  final String walletPin;
  final double amount;
  final int operatorId;
  final String phone;
  final String currency;
  final bool? addBeneficiary;

  DataPurchaseRequest({
    required this.walletPin,
    required this.amount,
    required this.operatorId,
    required this.phone,
    required this.currency,
    this.addBeneficiary,
  });

  Map<String, dynamic> toJson() => {
    'walletPin': walletPin,
    'amount': amount,
    'operatorId': operatorId,
    'phone': phone,
    'currency': currency,
    if (addBeneficiary != null) 'addBeneficiary': addBeneficiary,
  };
}

// Data Purchase Response
class DataPurchaseResponse {
  final String message;
  final int statusCode;

  DataPurchaseResponse({required this.message, required this.statusCode});

  factory DataPurchaseResponse.fromJson(Map<String, dynamic> json) =>
      DataPurchaseResponse(
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'] ?? 200,
      );
}

// Data Beneficiary Model
class DataBeneficiary {
  final String id;
  final String phoneNumber;
  final String? network;
  final int? operatorId;
  final String? userId;
  final String? type;
  final String? billType;
  final String? currency;
  final String? createdAt;
  final String? updatedAt;

  DataBeneficiary({
    required this.id,
    required this.phoneNumber,
    this.network,
    this.operatorId,
    this.userId,
    this.type,
    this.billType,
    this.currency,
    this.createdAt,
    this.updatedAt,
  });

  factory DataBeneficiary.fromJson(Map<String, dynamic> json) =>
      DataBeneficiary(
        id: json['id'] ?? '',
        phoneNumber:
            json['billerNumber'] ?? json['phoneNumber'] ?? json['phone'] ?? '',
        network: json['network'],
        operatorId: json['operatorId'],
        userId: json['userId'],
        type: json['type'],
        billType: json['billType'],
        currency: json['currency'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'phoneNumber': phoneNumber,
    'network': network,
    'operatorId': operatorId,
    'userId': userId,
    'type': type,
    'billType': billType,
    'currency': currency,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

// Data Beneficiaries Response
class DataBeneficiariesResponse {
  final List<DataBeneficiary> data;
  final String message;
  final int statusCode;
  final bool success;

  DataBeneficiariesResponse({
    required this.data,
    required this.message,
    required this.statusCode,
    required this.success,
  });

  factory DataBeneficiariesResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return DataBeneficiariesResponse(
      data:
          dataList
              .map(
                (item) =>
                    DataBeneficiary.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? true,
    );
  }
}
