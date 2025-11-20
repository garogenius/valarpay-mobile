// Models for Internet endpoints
class InternetPlanInfo {
  final String id;
  final String planName;
  final String countryISOCode;
  final String billerCode;

  InternetPlanInfo({
    required this.id,
    required this.planName,
    required this.countryISOCode,
    required this.billerCode,
  });

  factory InternetPlanInfo.fromJson(Map<String, dynamic> json) =>
      InternetPlanInfo(
        id: json['id']?.toString() ?? '',
        planName: json['planName'] ?? '',
        countryISOCode: json['countryISOCode'] ?? '',
        billerCode: json['billerCode'] ?? '',
      );
}

class InternetPlanResponse {
  final List<InternetPlanInfo> data;
  final String message;
  final int statusCode;

  InternetPlanResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory InternetPlanResponse.fromJson(Map<String, dynamic> json) {
    final list = <InternetPlanInfo>[];
    if (json['data'] != null && json['data'] is List) {
      list.addAll(
        (json['data'] as List).map(
          (e) => InternetPlanInfo.fromJson(e as Map<String, dynamic>),
        ),
      );
    }
    return InternetPlanResponse(
      data: list,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
    );
  }
}

class InternetVariationInfo {
  final int id;
  final String billerCode;
  final String name;
  final double fee;
  final String itemCode;
  final String labelName;
  final double amount;
  final bool isResolvable;
  final double? payAmount;

  InternetVariationInfo({
    required this.id,
    required this.billerCode,
    required this.name,
    required this.fee,
    required this.itemCode,
    required this.labelName,
    required this.amount,
    required this.isResolvable,
    this.payAmount,
  });

  factory InternetVariationInfo.fromJson(Map<String, dynamic> json) =>
      InternetVariationInfo(
        id: json['id'] ?? 0,
        billerCode: json['biller_code'] ?? json['billerCode'] ?? '',
        name: json['name'] ?? '',
        fee: (json['fee'] ?? 0).toDouble(),
        itemCode: json['item_code'] ?? json['itemCode'] ?? '',
        labelName: json['label_name'] ?? json['labelName'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        isResolvable: json['is_resolvable'] ?? json['isResolvable'] ?? false,
        payAmount:
            json['payAmount'] != null
                ? (json['payAmount'] as num).toDouble()
                : null,
      );
}

class InternetVariationResponse {
  final List<InternetVariationInfo> data;
  final String message;
  final int statusCode;

  InternetVariationResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory InternetVariationResponse.fromJson(Map<String, dynamic> json) {
    final list = <InternetVariationInfo>[];
    if (json['data'] != null && json['data'] is List) {
      list.addAll(
        (json['data'] as List).map(
          (e) => InternetVariationInfo.fromJson(e as Map<String, dynamic>),
        ),
      );
    }
    return InternetVariationResponse(
      data: list,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
    );
  }
}

class InternetPayRequest {
  final String walletPin;
  final bool? addBeneficiary;
  final String itemCode;
  final String billerCode;
  final String currency;
  final double amount;
  final String billerNumber;

  InternetPayRequest({
    required this.walletPin,
    this.addBeneficiary,
    required this.itemCode,
    required this.billerCode,
    required this.currency,
    required this.amount,
    required this.billerNumber,
  });

  Map<String, dynamic> toJson() => {
    'walletPin': walletPin,
    if (addBeneficiary != null) 'addBeneficiary': addBeneficiary,
    'itemCode': itemCode,
    'billerCode': billerCode,
    'currency': currency,
    'amount': amount,
    'billerNumber': billerNumber,
  };
}

class InternetPaymentResponse {
  final String message;
  final int statusCode;

  InternetPaymentResponse({required this.message, required this.statusCode});

  factory InternetPaymentResponse.fromJson(Map<String, dynamic> json) =>
      InternetPaymentResponse(
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'] ?? 200,
      );
}

// Internet Beneficiary Model
class InternetBeneficiary {
  final String id;
  final String phoneNumber;
  final String? providerName;
  final String? billerCode;
  final String? customerName;
  final String currency;
  final String userId;
  final String type;
  final String billType;

  InternetBeneficiary({
    required this.id,
    required this.phoneNumber,
    this.providerName,
    this.billerCode,
    this.customerName,
    required this.currency,
    required this.userId,
    required this.type,
    required this.billType,
  });

  factory InternetBeneficiary.fromJson(Map<String, dynamic> json) =>
      InternetBeneficiary(
        id: json['id']?.toString() ?? '',
        phoneNumber:
            json['phone_number'] ??
            json['phoneNumber'] ??
            json['billerNumber'] ??
            '',
        providerName: json['provider_name'] ?? json['providerName'],
        billerCode: json['biller_code'] ?? json['billerCode'],
        customerName: json['customer_name'] ?? json['customerName'],
        currency: json['currency']?.toString() ?? 'NGN',
        userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
        type: json['type']?.toString() ?? 'INTERNET',
        billType:
            json['bill_type']?.toString() ?? json['billType'] ?? 'internet',
      );

  @override
  String toString() =>
      'InternetBeneficiary(id: $id, phoneNumber: $phoneNumber, providerName: $providerName)';
}

class InternetBeneficiariesResponse {
  final List<InternetBeneficiary> data;
  final String message;
  final int statusCode;
  final bool success;

  InternetBeneficiariesResponse({
    required this.data,
    required this.message,
    required this.statusCode,
    required this.success,
  });

  factory InternetBeneficiariesResponse.fromJson(Map<String, dynamic> json) {
    final list = <InternetBeneficiary>[];
    if (json['data'] != null && json['data'] is List) {
      list.addAll(
        (json['data'] as List).map(
          (item) => InternetBeneficiary.fromJson(item as Map<String, dynamic>),
        ),
      );
    }
    return InternetBeneficiariesResponse(
      data: list,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? true,
    );
  }
}
