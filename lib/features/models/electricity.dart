class ElectricityPlan {
  final String id;
  final String planName;
  final String countryISOCode;
  final String billerCode;
  final String description;
  final String shortName;
  final String createdAt;
  final String updatedAt;
  final String? billerId;
  final String? billerName;
  final String? billerIcon;
  final String? itemCode;
  final String? itemName;
  final double amount;
  final String? category;

  ElectricityPlan({
    required this.id,
    required this.planName,
    required this.countryISOCode,
    required this.billerCode,
    required this.description,
    required this.shortName,
    required this.createdAt,
    required this.updatedAt,
    this.billerId,
    this.billerName,
    this.billerIcon,
    this.itemCode,
    this.itemName,
    this.amount = 0.0,
    this.category,
  });

  factory ElectricityPlan.fromJson(Map<String, dynamic> json) {
    return ElectricityPlan(
      id: json['id']?.toString() ?? json['billerId'] ?? '',
      planName: json['planName'] ?? json['itemName'] ?? json['name'] ?? json['billerName'] ?? '',
      countryISOCode: json['countryISOCode'] ?? '',
      billerCode: json['billerCode'] ?? json['billerId'] ?? '',
      description: json['description'] ?? '',
      shortName: json['shortName'] ?? json['itemName'] ?? json['billerName'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      billerId: json['billerId']?.toString(),
      billerName: json['billerName']?.toString(),
      billerIcon: json['billerIcon']?.toString(),
      itemCode: json['itemCode']?.toString(),
      itemName: json['itemName']?.toString(),
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      category: json['category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planName': planName,
      'countryISOCode': countryISOCode,
      'billerCode': billerCode,
      'description': description,
      'shortName': shortName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'billerId': billerId,
      'billerName': billerName,
      'billerIcon': billerIcon,
      'itemCode': itemCode,
      'itemName': itemName,
      'amount': amount,
      'category': category,
    };
  }
}

class ElectricityPlanResponse {
  final String message;
  final int statusCode;
  final List<ElectricityPlan> data;

  ElectricityPlanResponse({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory ElectricityPlanResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dataJson = json['data'] ?? json['billers'];
    return ElectricityPlanResponse(
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data:
          (dataJson is List)
              ? dataJson.map((item) => ElectricityPlan.fromJson(item)).toList()
              : (json['billers'] is List)
                  ? (json['billers'] as List).map((item) => ElectricityPlan.fromJson(item)).toList()
                  : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class ElectricityBillInfo {
  final int id;
  final String billerCode;
  final String name;
  final double defaultCommission;
  final String dateAdded;
  final String country;
  final bool isAirtime;
  final String billerName;
  final String itemCode;
  final String shortName;
  final double fee;
  final bool commissionOnFee;
  final String regExpression;
  final String labelName;
  final double amount;
  final bool isResolvable;
  final String groupName;
  final String categoryName;
  final dynamic isData;
  final dynamic defaultCommissionOnAmount;
  final int commissionOnFeeOrAmount;
  final dynamic validityPeriod;
  final double payAmount;

  ElectricityBillInfo({
    required this.id,
    required this.billerCode,
    required this.name,
    required this.defaultCommission,
    required this.dateAdded,
    required this.country,
    required this.isAirtime,
    required this.billerName,
    required this.itemCode,
    required this.shortName,
    required this.fee,
    required this.commissionOnFee,
    required this.regExpression,
    required this.labelName,
    required this.amount,
    required this.isResolvable,
    required this.groupName,
    required this.categoryName,
    this.isData,
    this.defaultCommissionOnAmount,
    required this.commissionOnFeeOrAmount,
    this.validityPeriod,
    required this.payAmount,
  });

  factory ElectricityBillInfo.fromJson(Map<String, dynamic> json) {
    return ElectricityBillInfo(
      id: json['id'] ?? json['itemId'] ?? 0,
      billerCode: json['biller_code'] ?? json['billerCode'] ?? json['billerId'] ?? '',
      name: json['name'] ?? json['itemName'] ?? '',
      defaultCommission: (json['default_commission'] ?? 0).toDouble(),
      dateAdded: json['date_added'] ?? '',
      country: json['country'] ?? '',
      isAirtime: json['is_airtime'] ?? false,
      billerName: json['biller_name'] ?? json['billerName'] ?? '',
      itemCode: json['item_code'] ?? json['itemCode'] ?? json['itemId'] ?? '',
      shortName: json['short_name'] ?? json['itemName'] ?? '',
      fee: (json['fee'] ?? 0).toDouble(),
      commissionOnFee: json['commission_on_fee'] ?? false,
      regExpression: json['reg_expression'] ?? '',
      labelName: json['label_name'] ?? json['itemName'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      isResolvable: json['is_resolvable'] ?? true,
      groupName: json['group_name'] ?? '',
      categoryName: json['category_name'] ?? '',
      isData: json['is_data'],
      defaultCommissionOnAmount: json['default_commission_on_amount'],
      commissionOnFeeOrAmount: json['commission_on_fee_or_amount'] ?? 0,
      validityPeriod: json['validity_period'],
      payAmount: (json['payAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'biller_code': billerCode,
      'name': name,
      'default_commission': defaultCommission,
      'date_added': dateAdded,
      'country': country,
      'is_airtime': isAirtime,
      'biller_name': billerName,
      'item_code': itemCode,
      'short_name': shortName,
      'fee': fee,
      'commission_on_fee': commissionOnFee,
      'reg_expression': regExpression,
      'label_name': labelName,
      'amount': amount,
      'is_resolvable': isResolvable,
      'group_name': groupName,
      'category_name': categoryName,
      'is_data': isData,
      'default_commission_on_amount': defaultCommissionOnAmount,
      'commission_on_fee_or_amount': commissionOnFeeOrAmount,
      'validity_period': validityPeriod,
      'payAmount': payAmount,
    };
  }
}

class ElectricityBillInfoResponse {
  final String message;
  final int statusCode;
  final List<ElectricityBillInfo> data;

  ElectricityBillInfoResponse({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory ElectricityBillInfoResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dataJson = json['data'] ?? json['items'];
    return ElectricityBillInfoResponse(
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data:
          (dataJson is List)
              ? dataJson.map((item) => ElectricityBillInfo.fromJson(item)).toList()
              : (json['items'] is List)
                  ? (json['items'] as List).map((item) => ElectricityBillInfo.fromJson(item)).toList()
                  : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class VerifyMeterNumberRequest {
  final String itemCode;
  final String billerCode;
  final String billerNumber;

  VerifyMeterNumberRequest({
    required this.itemCode,
    required this.billerCode,
    required this.billerNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'billerCode': billerCode,
      'billerNumber': billerNumber,
    };
  }
}

class VerifyMeterNumberResponse {
  final String message;
  final int statusCode;
  final VerifyMeterNumberData? data;

  VerifyMeterNumberResponse({
    required this.message,
    required this.statusCode,
    this.data,
  });

  factory VerifyMeterNumberResponse.fromJson(Map<String, dynamic> json) {
    return VerifyMeterNumberResponse(
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data:
          json['data'] != null
              ? VerifyMeterNumberData.fromJson(json['data'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': data?.toJson(),
    };
  }
}

class VerifyMeterNumberData {
  final String responseCode;
  final String address;
  final String responseMessage;
  final String name;
  final String billerCode;
  final String customer;
  final String productCode;
  final String? email;
  final double fee;
  final double maximum;
  final double minimum;

  VerifyMeterNumberData({
    required this.responseCode,
    required this.address,
    required this.responseMessage,
    required this.name,
    required this.billerCode,
    required this.customer,
    required this.productCode,
    this.email,
    required this.fee,
    required this.maximum,
    required this.minimum,
  });

  factory VerifyMeterNumberData.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return VerifyMeterNumberData(
      responseCode: json['response_code']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      responseMessage: json['response_message']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      billerCode: json['biller_code']?.toString() ?? '',
      customer: json['customer']?.toString() ?? '',
      productCode: json['product_code']?.toString() ?? '',
      email: json['email']?.toString(),
      fee: parseDouble(json['fee']),
      maximum: parseDouble(json['maximum']),
      minimum: parseDouble(json['minimum']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_code': responseCode,
      'address': address,
      'response_message': responseMessage,
      'name': name,
      'biller_code': billerCode,
      'customer': customer,
      'product_code': productCode,
      'email': email,
      'fee': fee,
      'maximum': maximum,
      'minimum': minimum,
    };
  }
}

class ElectricityPaymentRequest {
  final String walletPin;
  final String itemCode;
  final String billerCode;
  final String currency;
  final String billerNumber;
  final double amount;

  ElectricityPaymentRequest({
    required this.walletPin,
    required this.itemCode,
    required this.billerCode,
    required this.currency,
    required this.billerNumber,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'walletPin': walletPin,
      'itemCode': itemCode,
      'billerCode': billerCode,
      'currency': currency,
      'billerNumber': billerNumber,
      'amount': amount,
    };
  }
}

class ElectricityPaymentResponse {
  final String message;
  final int statusCode;
  final ElectricityPaymentData data;

  ElectricityPaymentResponse({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory ElectricityPaymentResponse.fromJson(Map<String, dynamic> json) {
    return ElectricityPaymentResponse(
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: ElectricityPaymentData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': data.toJson(),
    };
  }
}

class ElectricityPaymentData {
  final String rechargeToken;

  ElectricityPaymentData({required this.rechargeToken});

  factory ElectricityPaymentData.fromJson(Map<String, dynamic> json) {
    return ElectricityPaymentData(rechargeToken: json['recharge_token'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'recharge_token': rechargeToken};
  }
}

// Electricity Beneficiary Model
class ElectricityBeneficiary {
  final String id;
  final String meterNumber;
  final String? discoName;
  final String? meterType;
  final String? customerName;
  final String? userId;
  final String? type;
  final String? billType;
  final String? currency;
  final String? createdAt;
  final String? updatedAt;
  final String? network;
  final String? operatorId;

  ElectricityBeneficiary({
    required this.id,
    required this.meterNumber,
    this.discoName,
    this.meterType,
    this.customerName,
    this.userId,
    this.type,
    this.billType,
    this.currency,
    this.createdAt,
    this.updatedAt,
    this.network,
    this.operatorId,
  });

  factory ElectricityBeneficiary.fromJson(Map<String, dynamic> json) =>
      ElectricityBeneficiary(
        id: json['id'] ?? '',
        meterNumber:
            json['meterNumber'] ??
            json['meter_number'] ??
            json['billerNumber'] ??
            '',
        discoName: json['discoName'] ?? json['disco_name'],
        meterType: json['meterType'] ?? json['meter_type'],
        customerName: json['customerName'] ?? json['customer_name'],
        userId: json['userId'] ?? json['user_id'],
        type: json['type'],
        billType: json['billType'] ?? json['bill_type'],
        currency: json['currency'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        network: json['network'],
        operatorId:
            json['operatorId']?.toString() ?? json['operator_id']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'meterNumber': meterNumber,
    'discoName': discoName,
    'meterType': meterType,
    'customerName': customerName,
    'userId': userId,
    'type': type,
    'billType': billType,
    'currency': currency,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'network': network,
    'operatorId': operatorId,
  };
}

// Electricity Beneficiaries Response
class ElectricityBeneficiariesResponse {
  final List<ElectricityBeneficiary> data;
  final String message;
  final int statusCode;
  final bool success;

  ElectricityBeneficiariesResponse({
    required this.data,
    required this.message,
    required this.statusCode,
    required this.success,
  });

  factory ElectricityBeneficiariesResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return ElectricityBeneficiariesResponse(
      data:
          dataList
              .map(
                (item) => ElectricityBeneficiary.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? true,
    );
  }
}
