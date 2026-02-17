// Airtime Plan Models
class AirtimePlan {
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
  final double minAmount;
  final double maxAmount;
  final double? localMinAmount;
  final double? localMaxAmount;
  final Country country;
  final FxRate fx;
  final List<String> logoUrls;
  final List<double> fixedAmounts;
  final Map<String, dynamic> fixedAmountsDescriptions;
  final List<double> localFixedAmounts;
  final Map<String, dynamic> localFixedAmountsDescriptions;
  final List<double> suggestedAmounts;
  final Map<String, dynamic> suggestedAmountsMap;
  final Fees fees;
  final List<dynamic> geographicalRechargePlans;
  final List<dynamic> promotions;
  final String status;
  final double? payAmount;

  AirtimePlan({
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
    required this.minAmount,
    required this.maxAmount,
    this.localMinAmount,
    this.localMaxAmount,
    required this.country,
    required this.fx,
    required this.logoUrls,
    required this.fixedAmounts,
    required this.fixedAmountsDescriptions,
    required this.localFixedAmounts,
    required this.localFixedAmountsDescriptions,
    required this.suggestedAmounts,
    required this.suggestedAmountsMap,
    required this.fees,
    required this.geographicalRechargePlans,
    required this.promotions,
    required this.status,
    this.payAmount,
  });

  factory AirtimePlan.fromJson(Map<String, dynamic> json) => AirtimePlan(
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
    minAmount: (json['minAmount'] ?? 0).toDouble(),
    maxAmount: (json['maxAmount'] ?? 0).toDouble(),
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
    localFixedAmountsDescriptions: Map<String, dynamic>.from(
      json['localFixedAmountsDescriptions'] ?? {},
    ),
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
    payAmount: json['payAmount']?.toDouble(),
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

// Airtime Plan Response
class AirtimePlanResponse {
  final String? network;
  final AirtimePlan plan;
  final String message;
  final int statusCode;

  AirtimePlanResponse({
    this.network,
    required this.plan,
    required this.message,
    required this.statusCode,
  });

  factory AirtimePlanResponse.fromJson(Map<String, dynamic> json) =>
      AirtimePlanResponse(
        network: json['data']?['network'],
        plan: AirtimePlan.fromJson(json['data']?['plan'] ?? json['data'] ?? {}),
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'] ?? 200,
      );
}

// International FX Rate Models
class InternationalFxRate {
  final int id;
  final String name;
  final double fxRate;
  final String currencyCode;

  InternationalFxRate({
    required this.id,
    required this.name,
    required this.fxRate,
    required this.currencyCode,
  });

  factory InternationalFxRate.fromJson(Map<String, dynamic> json) =>
      InternationalFxRate(
        id: json['id'] ?? 0,
        name: json['name'] ?? json['fromCurrency'] ?? '',
        fxRate: (json['exchangeRate'] ?? json['fxRate'] ?? json['rate'] ?? 0).toDouble(),
        currencyCode: json['currencyCode'] ?? json['fromCurrency'] ?? '',
      );
}

class InternationalFxRateResponse {
  final InternationalFxRate data;
  final String message;
  final int statusCode;

  InternationalFxRateResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory InternationalFxRateResponse.fromJson(Map<String, dynamic> json) =>
      InternationalFxRateResponse(
        data: InternationalFxRate.fromJson(json['data'] ?? {}),
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'] ?? 200,
      );
}

// Airtime Purchase Request
class AirtimePurchaseRequest {
  final String walletPin;
  final double amount;
  final int? operatorId;
  final String? billerId;
  final String? itemId;
  final String phone;
  final String currency;
  final bool? addBeneficiary;

  AirtimePurchaseRequest({
    required this.walletPin,
    required this.amount,
    this.operatorId,
    this.billerId,
    this.itemId,
    required this.phone,
    required this.currency,
    this.addBeneficiary,
  });

  Map<String, dynamic> toJson() => {
    'walletPin': walletPin,
    'amount': amount,
    if (operatorId != null) 'operatorId': operatorId,
    'phone': phone,
    'currency': currency,
    if (addBeneficiary != null) 'addBeneficiary': addBeneficiary,
  };
}

// Airtime Purchase Response
class AirtimePurchaseResponse {
  final String message;
  final int statusCode;
  final bool success;

  AirtimePurchaseResponse({
    required this.message,
    required this.statusCode,
    required this.success,
  });

  factory AirtimePurchaseResponse.fromJson(Map<String, dynamic> json) =>
      AirtimePurchaseResponse(
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'] ?? 200,
        success: json['success'] ?? true,
      );
}

// Airtime Beneficiary Model
class AirtimeBeneficiary {
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

  AirtimeBeneficiary({
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

  factory AirtimeBeneficiary.fromJson(Map<String, dynamic> json) =>
      AirtimeBeneficiary(
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

// Airtime Beneficiaries Response
class AirtimeBeneficiariesResponse {
  final List<AirtimeBeneficiary> data;
  final String message;
  final int statusCode;
  final bool success;

  AirtimeBeneficiariesResponse({
    required this.data,
    required this.message,
    required this.statusCode,
    required this.success,
  });

  factory AirtimeBeneficiariesResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return AirtimeBeneficiariesResponse(
      data:
          dataList
              .map(
                (item) =>
                    AirtimeBeneficiary.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? true,
    );
  }
}
