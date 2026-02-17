// Models for Cable TV endpoints
class CablePlanInfo {
  final String id;
  final String planName;
  final String countryISOCode;
  final String billerCode;
  final String? billerId;
  final String? billerName;
  final String? billerIcon;

  CablePlanInfo({
    required this.id,
    required this.planName,
    required this.countryISOCode,
    required this.billerCode,
    this.billerId,
    this.billerName,
    this.billerIcon,
  });

  factory CablePlanInfo.fromJson(Map<String, dynamic> json) => CablePlanInfo(
    id: json['id']?.toString() ?? json['billerId'] ?? '',
    planName: json['planName'] ?? json['name'] ?? json['billerName'] ?? '',
    countryISOCode: json['countryISOCode'] ?? '',
    billerCode: json['billerCode'] ?? json['biller_code'] ?? json['billerId'] ?? '',
    billerId: json['billerId']?.toString(),
    billerName: json['billerName']?.toString(),
    billerIcon: json['billerIcon']?.toString(),
  );
}

class CablePlanResponse {
  final List<CablePlanInfo> data;
  final String message;
  final int statusCode;

  CablePlanResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory CablePlanResponse.fromJson(Map<String, dynamic> json) {
    final list = <CablePlanInfo>[];
    final dynamic dataJson = json['data'] ?? json['billers'];
    
    if (dataJson != null && dataJson is List) {
      list.addAll(
        (dataJson).map(
          (e) => CablePlanInfo.fromJson(e as Map<String, dynamic>),
        ),
      );
    } else if (json['billers'] != null && json['billers'] is List) {
      list.addAll(
        (json['billers'] as List).map(
          (e) => CablePlanInfo.fromJson(e as Map<String, dynamic>),
        ),
      );
    }
    return CablePlanResponse(
      data: list,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
    );
  }
}

class CableVariationInfo {
  final dynamic id;
  final String billerCode;
  final String name;
  final double fee;
  final String itemCode;
  final String labelName;
  final double amount;
  final bool isResolvable;
  final double? payAmount;
  final String? itemId;
  final String? itemName;
  final String? billerId;

  CableVariationInfo({
    required this.id,
    required this.billerCode,
    required this.name,
    required this.fee,
    required this.itemCode,
    required this.labelName,
    required this.amount,
    required this.isResolvable,
    this.payAmount,
    this.itemId,
    this.itemName,
    this.billerId,
  });

  factory CableVariationInfo.fromJson(Map<String, dynamic> json) =>
      CableVariationInfo(
        id: json['id'] ?? json['itemId'] ?? 0,
        billerCode: json['biller_code'] ?? json['billerCode'] ?? json['billerId'] ?? '',
        name: json['name'] ?? json['itemName'] ?? '',
        fee: (json['fee'] ?? 0).toDouble(),
        itemCode: json['item_code'] ?? json['itemCode'] ?? json['itemId'] ?? '',
        labelName: json['label_name'] ?? json['labelName'] ?? json['itemName'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        isResolvable: json['is_resolvable'] ?? json['isResolvable'] ?? true,
        payAmount:
            json['payAmount'] != null
                ? (json['payAmount'] as num).toDouble()
                : null,
        itemId: json['itemId']?.toString(),
        itemName: json['itemName']?.toString(),
        billerId: json['billerId']?.toString(),
      );
}

class CableVariationResponse {
  final List<CableVariationInfo> data;
  final String message;
  final int statusCode;

  CableVariationResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory CableVariationResponse.fromJson(Map<String, dynamic> json) {
    final list = <CableVariationInfo>[];
    final dynamic dataJson = json['data'] ?? json['items'];

    if (dataJson != null && dataJson is List) {
      list.addAll(
        (dataJson).map(
          (e) => CableVariationInfo.fromJson(e as Map<String, dynamic>),
        ),
      );
    } else if (dataJson != null &&
        dataJson is Map &&
        dataJson['plans'] is List) {
      final String billerCode =
          dataJson['billerCode'] ?? json['billerCode'] ?? '';
      list.addAll(
        (dataJson['plans'] as List).map((e) {
          final map = e as Map<String, dynamic>;
          return CableVariationInfo(
            id: map['id'],
            billerCode: billerCode,
            name: map['name'] ?? '',
            fee: 0,
            itemCode: map['id']?.toString() ?? '',
            labelName: map['name'] ?? '',
            amount: (map['amount'] ?? 0).toDouble(),
            isResolvable: true,
            payAmount: (map['amount'] ?? 0).toDouble(),
          );
        }),
      );
    } else if (json['items'] != null && json['items'] is List) {
      list.addAll(
        (json['items'] as List).map(
          (e) => CableVariationInfo.fromJson(e as Map<String, dynamic>),
        ),
      );
    }
    return CableVariationResponse(
      data: list,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
    );
  }
}

class VerifyCableRequest {
  final String itemCode;
  final String billerCode;
  final String billerNumber;

  VerifyCableRequest({
    required this.itemCode,
    required this.billerCode,
    required this.billerNumber,
  });

  Map<String, dynamic> toJson() => {
    'itemCode': itemCode,
    'billerCode': billerCode,
    'billerNumber': billerNumber,
  };
}

class VerifyCableData {
  final String responseCode;
  final String? address;
  final String responseMessage;
  final String name;
  final String billerCode;
  final String customer;
  final String productCode;
  final String? email;
  final double fee;
  final double maximum;
  final double minimum;

  VerifyCableData({
    required this.responseCode,
    this.address,
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

  factory VerifyCableData.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return VerifyCableData(
      responseCode:
          json['response_code']?.toString() ??
          json['responseCode']?.toString() ??
          '',
      address: json['address']?.toString(),
      responseMessage:
          json['response_message']?.toString() ??
          json['responseMessage']?.toString() ??
          '',
      name: json['name']?.toString() ?? '',
      billerCode:
          json['biller_code']?.toString() ??
          json['billerCode']?.toString() ??
          '',
      customer: json['customer']?.toString() ?? '',
      productCode:
          json['product_code']?.toString() ??
          json['productCode']?.toString() ??
          '',
      email: json['email']?.toString(),
      fee: parseDouble(json['fee']),
      maximum: parseDouble(json['maximum']),
      minimum: parseDouble(json['minimum']),
    );
  }
}

class VerifyCableResponse {
  final VerifyCableData? data;
  final String message;
  final int statusCode;

  VerifyCableResponse({
    this.data,
    required this.message,
    required this.statusCode,
  });

  factory VerifyCableResponse.fromJson(Map<String, dynamic> json) {
    VerifyCableData? data;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = VerifyCableData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      );
    }
    return VerifyCableResponse(
      data: data,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
    );
  }
}

class CablePayRequest {
  final String itemCode;
  final String billerCode;
  final String currency;
  final String billerNumber;
  final double amount;
  final String walletPin;

  CablePayRequest({
    required this.itemCode,
    required this.billerCode,
    required this.currency,
    required this.billerNumber,
    required this.amount,
    required this.walletPin,
  });

  Map<String, dynamic> toJson() => {
    'itemCode': itemCode,
    'billerCode': billerCode,
    'currency': currency,
    'billerNumber': billerNumber,
    'amount': amount,
    'walletPin': walletPin,
  };
}

class CablePaymentResponse {
  final String message;
  final int statusCode;

  CablePaymentResponse({required this.message, required this.statusCode});

  factory CablePaymentResponse.fromJson(Map<String, dynamic> json) =>
      CablePaymentResponse(
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'] ?? 200,
      );
}

// Cable TV Beneficiary Models
class CableBeneficiary {
  final String id;
  final String smartCardNumber;
  final String? providerName;
  final String? billerCode;
  final String? customerName;
  final String currency;
  final String userId;
  final String type;
  final String billType;

  CableBeneficiary({
    required this.id,
    required this.smartCardNumber,
    this.providerName,
    this.billerCode,
    this.customerName,
    required this.currency,
    required this.userId,
    required this.type,
    required this.billType,
  });

  factory CableBeneficiary.fromJson(Map<String, dynamic> json) =>
      CableBeneficiary(
        id: json['id']?.toString() ?? '',
        smartCardNumber:
            json['smart_card_number'] ??
            json['smartCardNumber'] ??
            json['billerNumber'] ??
            '',
        providerName: json['provider_name'] ?? json['providerName'],
        billerCode: json['biller_code'] ?? json['billerCode'],
        customerName: json['customer_name'] ?? json['customerName'],
        currency: json['currency']?.toString() ?? 'NGN',
        userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
        type: json['type']?.toString() ?? 'CABLE',
        billType: json['bill_type']?.toString() ?? json['billType'] ?? 'cable',
      );

  @override
  String toString() =>
      'CableBeneficiary(id: $id, smartCardNumber: $smartCardNumber, providerName: $providerName)';
}

class CableBeneficiariesResponse {
  final List<CableBeneficiary> data;
  final String message;
  final int statusCode;
  final bool success;

  CableBeneficiariesResponse({
    required this.data,
    required this.message,
    required this.statusCode,
    required this.success,
  });

  factory CableBeneficiariesResponse.fromJson(Map<String, dynamic> json) {
    final list = <CableBeneficiary>[];
    if (json['data'] != null && json['data'] is List) {
      list.addAll(
        (json['data'] as List).map(
          (e) => CableBeneficiary.fromJson(e as Map<String, dynamic>),
        ),
      );
    }
    return CableBeneficiariesResponse(
      data: list,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? true,
    );
  }
}
