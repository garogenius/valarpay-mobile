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

// Data Plan Info (Now matching the new simplified response)
class DataPlanInfo {
  final dynamic id;
  final String network;
  final String name;
  final double amount;
  final String validity;
  final String? billerId;
  final String? billerName;
  final String? billerIcon;

  DataPlanInfo({
    required this.id,
    required this.network,
    required this.name,
    required this.amount,
    required this.validity,
    this.billerId,
    this.billerName,
    this.billerIcon,
  });

  factory DataPlanInfo.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    final dynamic rawId = json['id'] ?? json['billerId'] ?? json['variation_code'] ?? json['variationCode'] ?? '';

    return DataPlanInfo(
      id: rawId,
      network: json['network'] ?? json['operatorName'] ?? json['billerName'] ?? '',
      name: json['name'] ?? json['variationName'] ?? json['planName'] ?? json['billerName'] ?? '',
      amount: parseDouble(json['amount'] ?? json['variationAmount'] ?? json['price'] ?? json['minAmount']),
      validity: json['validity'] ?? json['variationValidity'] ?? '',
      billerId: json['billerId']?.toString(),
      billerName: json['billerName']?.toString(),
      billerIcon: json['billerIcon']?.toString(),
    );
  }
}

// Data Plan Response with plans array
class DataPlanResponse {
  final List<DataPlanInfo> plans;
  final String message;
  final int statusCode;

  DataPlanResponse({
    required this.plans,
    required this.message,
    required this.statusCode,
  });

  factory DataPlanResponse.fromJson(Map<String, dynamic> json) {
    var dataJson = json['data'] ?? json['billers']; // Support 'billers' for PalmPay
    List<DataPlanInfo> plansList = [];

    if (dataJson is List) {
      plansList = dataJson.map((p) => DataPlanInfo.fromJson(p)).toList();
    } else if (dataJson is Map) {
      final dynamic nestedData = dataJson['plans'] ?? dataJson['variations'] ?? dataJson['data'] ?? dataJson['billers'];
      if (nestedData is List) {
        plansList = nestedData.map((p) => DataPlanInfo.fromJson(p)).toList();
      } else if (dataJson.containsKey('id') || dataJson.containsKey('operatorId') || dataJson.containsKey('network') || dataJson.containsKey('billerId')) {
        // The data object itself is the operator info
        plansList = [DataPlanInfo.fromJson(Map<String, dynamic>.from(dataJson))];
      }
    } else if (json['billers'] is List) {
      plansList = (json['billers'] as List).map((p) => DataPlanInfo.fromJson(p)).toList();
    }

    return DataPlanResponse(
      plans: plansList,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
    );
  }
}

// Simplified Data Plan Bundle model for the new endpoints
class DataExtInfo {
  final int? validityDate;
  final String? itemSize;
  final String? itemDescription;
  final String? validityAttachNote;
  final String? validity;

  DataExtInfo({
    this.validityDate,
    this.itemSize,
    this.itemDescription,
    this.validityAttachNote,
    this.validity,
  });

  factory DataExtInfo.fromJson(Map<String, dynamic> json) {
    return DataExtInfo(
      validityDate: json['validityDate'] is int 
          ? json['validityDate'] 
          : int.tryParse(json['validityDate']?.toString() ?? ''),
      itemSize: json['itemSize'],
      itemDescription: json['itemDescription'],
      validityAttachNote: json['validityAttachNote'],
      validity: json['validity'],
    );
  }
}

class DataPlanBundle {
  final String id;
  final int? operatorId;
  final String name;
  final double amount;
  final String validity;
  final String? network;
  final String? billerId;
  final DataExtInfo? extInfo;

  DataPlanBundle({
    required this.id,
    this.operatorId,
    required this.name,
    required this.amount,
    required this.validity,
    this.network,
    this.billerId,
    this.extInfo,
  });

  factory DataPlanBundle.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    // Handle various possible keys for each field
    final dynamic rawId = json['id'] ?? json['itemId'] ?? json['variation_code'] ?? json['variationCode'] ?? '';
    String id = rawId.toString();
    
    if (id.isEmpty) {
      final opId = json['operatorId'] ?? 0;
      final amt = json['localAmount'] ?? json['amount'] ?? 0;
      id = '$opId-$amt';
    }
    
    String name = json['name'] ?? 
                       json['itemName'] ??
                       json['variation_name'] ?? 
                       json['variationName'] ?? 
                       json['planName'] ?? 
                       json['billerName'] ?? 
                       json['description'] ??
                       '';
    
    DataExtInfo? extInfo;
    if (json['extInfo'] != null && json['extInfo'] is Map) {
      extInfo = DataExtInfo.fromJson(json['extInfo']);
      final String? itemSize = json['extInfo']['itemSize'];
      if (itemSize != null && itemSize.isNotEmpty) {
        name = itemSize;
      }
    }
                       
    final double rawAmount = parseDouble(
      json['amount'] ?? 
      json['variation_amount'] ?? 
      json['variationAmount'] ?? 
      json['price'] ?? 
      json['fixedAmount']
    );

    // Removed PalmPay / 100 logic since we migrated to new biller endpoint
    final double amount = rawAmount;
    
    String validity = json['validity'] ?? 
                          json['variation_validity'] ?? 
                          json['plan_validity'] ?? 
                          '';
    
    if (validity.isEmpty && json['extInfo'] != null && json['extInfo'] is Map) {
      validity = json['extInfo']['validity'] ?? '';
    }

    if (validity.isEmpty && name.toLowerCase().contains('valid for')) {
      final parts = name.toLowerCase().split('valid for');
      if (parts.length > 1) {
        validity = parts.last.trim();
      }
    }

    // Extract cleaner names from the raw description/name (e.g. 2GB 30days)
    String rawName = name;
    final lowerName = rawName.toLowerCase();
    
    final dataMatch = RegExp(r'(\d+(?:\.\d+)?\s*(?:MB|GB|TB))', caseSensitive: false).firstMatch(rawName);
    String extractedData = dataMatch != null ? dataMatch.group(1)!.toUpperCase().replaceAll(' ', '') : '';
    
    String extractedValidity = '';
    if (lowerName.contains('daily') || lowerName.contains('1 day') || lowerName.contains('1-day') || lowerName.contains('1days')) {
      extractedValidity = 'Daily';
    } else if (lowerName.contains('2 day') || lowerName.contains('2-day') || lowerName.contains('2days')) {
      extractedValidity = '2 Days';
    } else if (lowerName.contains('weekly') || lowerName.contains('7 day') || lowerName.contains('7-day') || lowerName.contains('7days')) {
      extractedValidity = 'Weekly';
    } else if (lowerName.contains('30 day') || lowerName.contains('monthly') || lowerName.contains('1 month') || lowerName.contains('30days')) {
      extractedValidity = '30 Days';
    } else if (lowerName.contains('60 day') || lowerName.contains('2 month') || lowerName.contains('60days')) {
      extractedValidity = '60 Days';
    } else if (lowerName.contains('yearly') || lowerName.contains('365 day') || lowerName.contains('1 year')) {
      extractedValidity = 'Yearly';
    } else {
      final validMatch = RegExp(r'valid(?:ity)?(?: for)?(?::)?\s*(\d+\s*days?)', caseSensitive: false).firstMatch(rawName);
      if (validMatch != null) {
        extractedValidity = validMatch.group(1)!;
      } else {
        final daysMatch = RegExp(r'(\d+)\s*days?', caseSensitive: false).firstMatch(rawName);
        if (daysMatch != null) {
          extractedValidity = daysMatch.group(1)!;
        }
      }
    }

    if (extractedValidity.isEmpty && validity.isNotEmpty) {
      extractedValidity = validity;
    }

    if (extractedData.isNotEmpty) {
      name = extractedData;
      validity = extractedValidity.isNotEmpty ? extractedValidity : '';
    } else {
      if (extractedValidity.isNotEmpty) {
         validity = extractedValidity;
      }
    }

    return DataPlanBundle(
      id: id,
      operatorId: json['operatorId'],
      name: name,
      amount: amount,
      validity: validity,
      network: json['network']?.toString(),
      billerId: json['billerId']?.toString(),
      extInfo: extInfo,
    );
  }
}

// Data Variation Response (Now used for bundles)
class DataVariationResponse {
  final List<DataPlanBundle> data;
  final String message;
  final int statusCode;

  DataVariationResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory DataVariationResponse.fromJson(Map<String, dynamic> json) {
    var dataJson = json['data'] ?? json['items'];
    List<DataPlanBundle> plans = [];
    
    if (dataJson is List) {
      plans = dataJson.map((p) => DataPlanBundle.fromJson(p)).toList();
    } else if (dataJson is Map) {
       // CASE 1: Response has an 'operators' list
       if (dataJson.containsKey('operators') && dataJson['operators'] is List) {
         final operators = dataJson['operators'] as List<dynamic>;
         for (var op in operators) {
            if (op is Map && op.containsKey('plans') && op['plans'] is List) {
               final opPlans = op['plans'] as List<dynamic>;
               final networkName = op['network']?.toString() ?? op['name']?.toString();
               final int opId = op['operatorId'] ?? 0;
               
               for (var p in opPlans) {
                  if (p is Map<String, dynamic>) {
                    p['network'] ??= networkName;
                    if (!p.containsKey('operatorId')) {
                      p['operatorId'] = opId;
                    }
                  }
                  plans.add(DataPlanBundle.fromJson(p as Map<String, dynamic>));
               }
            }
         }
       }
       // CASE 2: Response has a nested list
       else if ((dataJson['plans'] ?? dataJson['variations'] ?? dataJson['data'] ?? dataJson['items']) is List) {
         final List<dynamic> list = (dataJson['plans'] ?? dataJson['variations'] ?? dataJson['data'] ?? dataJson['items']) as List<dynamic>;
         plans = list.map((p) => DataPlanBundle.fromJson(p)).toList();
       } 
       // CASE 3: Response is the operator object itself with fixedAmountsDescriptions (Log 1)
       else if (dataJson.containsKey('fixedAmounts') || dataJson.containsKey('localFixedAmounts')) {
         final List<dynamic> amounts = (dataJson['localFixedAmounts'] ?? dataJson['fixedAmounts']) as List<dynamic>;
         final Map<String, dynamic> descriptions = Map<String, dynamic>.from(
           dataJson['localFixedAmountsDescriptions'] ?? dataJson['fixedAmountsDescriptions'] ?? {}
         );
         final String? network = dataJson['network']?.toString() ?? dataJson['name']?.toString();
         final int opId = dataJson['id'] ?? dataJson['operatorId'] ?? 0;
         
         for (var amt in amounts) {
           final double value = (amt is num) ? amt.toDouble() : double.tryParse(amt.toString()) ?? 0;
           
           // Try to find the matching description
           String? desc;
           if (amt is String && descriptions.containsKey(amt)) {
             desc = descriptions[amt];
           } else {
              for (var entry in descriptions.entries) {
                if ((double.tryParse(entry.key) ?? -1) == value) {
                  desc = entry.value;
                  break;
                }
              }
           }

           String validity = '';
           if (desc != null && desc.contains('(') && desc.contains(')')) {
             final start = desc.lastIndexOf('(') + 1;
             final end = desc.lastIndexOf(')');
             if (end > start) {
               validity = desc.substring(start, end);
             }
           }

           plans.add(DataPlanBundle(
             id: '$opId-$value', // Unique selection ID
             operatorId: opId,
             name: desc ?? 'Data Plan',
             amount: value,
             validity: validity,
             network: network,
           ));
         }
       }
    }

    return DataVariationResponse(
      data: plans,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
    );
  }
}

// Data Purchase Request
class DataPurchaseRequest {
  final String walletPin;
  final double amount;
  final int? operatorId;
  final String? billerId;
  final String? itemId;
  final String phone;
  final String currency;
  final bool? addBeneficiary;

  DataPurchaseRequest({
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
    if (billerId != null) 'billerId': billerId,
    if (itemId != null) 'itemId': itemId,
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
