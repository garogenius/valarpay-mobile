class RemitaCategory {
  final String categoryId;
  final String categoryName;

  RemitaCategory({required this.categoryId, required this.categoryName});

  factory RemitaCategory.fromJson(Map<String, dynamic> json) => RemitaCategory(
        categoryId: json['categoryId']?.toString() ?? '',
        categoryName: json['categoryName']?.toString() ?? '',
      );
}

class RemitaBiller {
  final String billerId;
  final String billerName;
  final String? billerShortName;
  final String? billerLogoUrl;
  final String? description;

  RemitaBiller({
    required this.billerId,
    required this.billerName,
    this.billerShortName,
    this.billerLogoUrl,
    this.description,
  });

  factory RemitaBiller.fromJson(Map<String, dynamic> json) => RemitaBiller(
        billerId: json['billerId']?.toString() ?? json['id']?.toString() ?? json['code']?.toString() ?? json['biller_code']?.toString() ?? '',
        billerName: json['billerName'] ?? json['name'] ?? json['biller_name'] ?? json['short_name'] ?? '',
        billerShortName: json['billerShortName']?.toString() ?? json['short_name']?.toString(),
        billerLogoUrl: json['billerLogoUrl'] ?? json['logoUrl'] ?? json['logo_url'],
        description: json['description'],
      );
}

class RemitaProduct {
  final String billPaymentProductId;
  final String billPaymentProductName;
  final String? serviceCode;
  final double? amount;
  final bool? isAmountFixed;
  final List<RemitaCustomField>? customFields;

  RemitaProduct({
    required this.billPaymentProductId,
    required this.billPaymentProductName,
    this.serviceCode,
    this.amount,
    this.isAmountFixed,
    this.customFields,
  });

  factory RemitaProduct.fromJson(Map<String, dynamic> json) {
    return RemitaProduct(
      billPaymentProductId: json['billPaymentProductId'] ?? json['id']?.toString() ?? json['item_code']?.toString() ?? json['biller_name']?.toString() ?? '',
      billPaymentProductName: json['billPaymentProductName'] ?? json['name'] ?? json['biller_name'] ?? json['short_name'] ?? '',
      serviceCode: json['service_code']?.toString() ?? json['serviceCode']?.toString(),
      amount: (json['amount'] ?? json['fee'] ?? 0.0).toDouble(),
      isAmountFixed: json['isAmountFixed'],
      customFields: json['customFields'] != null
          ? (json['customFields'] as List).map((i) => RemitaCustomField.fromJson(i)).toList()
          : null,
    );
  }
}

class RemitaCustomField {
  final String variableName;
  final String displayName;
  final String type;
  final bool required;

  RemitaCustomField({
    required this.variableName,
    required this.displayName,
    required this.type,
    required this.required,
  });

  factory RemitaCustomField.fromJson(Map<String, dynamic> json) => RemitaCustomField(
        variableName: json['variable_name'] ?? json['variableName'] ?? '',
        displayName: json['display_name'] ?? json['displayName'] ?? '',
        type: json['type'] ?? 'string',
        required: json['required'] ?? false,
      );
}

class RemitaCustomerValidation {
  final String customerName;
  final String? address;
  final double? minimumAmount;
  final List<dynamic>? valueList;

  RemitaCustomerValidation({
    required this.customerName,
    this.address,
    this.minimumAmount,
    this.valueList,
  });

  factory RemitaCustomerValidation.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return RemitaCustomerValidation(
      customerName: data['customerName'] ?? data['name'] ?? '',
      address: data['address'],
      minimumAmount: (data['minimumAmount'] ?? 0.0).toDouble(),
      valueList: data['valueList'],
    );
  }
}

class RemitaInitiationResponse {
  final String rrr;
  final String paymentIdentifier;
  final double amount;

  RemitaInitiationResponse({
    required this.rrr,
    required this.paymentIdentifier,
    required this.amount,
  });

  factory RemitaInitiationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return RemitaInitiationResponse(
      rrr: data['rrr'] ?? '',
      paymentIdentifier: data['paymentIdentifier'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
    );
  }
}

class RemitaPaymentRequest {
  final String rrr;
  final String paymentIdentifier;
  final double amount;
  final String currency;
  final String walletPin;

  RemitaPaymentRequest({
    required this.rrr,
    required this.paymentIdentifier,
    required this.amount,
    this.currency = 'NGN',
    required this.walletPin,
  });

  Map<String, dynamic> toJson() => {
        'rrr': rrr,
        'paymentIdentifier': paymentIdentifier,
        'amount': amount,
        'currency': currency,
        'walletPin': walletPin,
      };
}

class RemitaPaymentResponse {
  final String message;
  final String transactionRef;
  final double amount;
  final String rrr;
  final String paymentIdentifier;
  final String transactionStatus;
  final double balance;

  RemitaPaymentResponse({
    required this.message,
    required this.transactionRef,
    required this.amount,
    required this.rrr,
    required this.paymentIdentifier,
    required this.transactionStatus,
    required this.balance,
  });

  factory RemitaPaymentResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return RemitaPaymentResponse(
      message: json['message'] ?? '',
      transactionRef: data['transactionRef'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      rrr: data['rrr'] ?? '',
      paymentIdentifier: data['paymentIdentifier'] ?? '',
      transactionStatus: data['transactionStatus'] ?? '',
      balance: (data['balance'] ?? 0.0).toDouble(),
    );
  }
}

class RemitaInitiateRequest {
  final String billPaymentProductId;
  final double amount;
  final String name;
  final String paymentIdentifier;
  final String email;
  final String phoneNumber;
  final String customerId;
  final Map<String, dynamic>? metadata;

  RemitaInitiateRequest({
    required this.billPaymentProductId,
    required this.amount,
    required this.name,
    required this.paymentIdentifier,
    required this.email,
    required this.phoneNumber,
    required this.customerId,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'billPaymentProductId': billPaymentProductId,
        'amount': amount,
        'name': name,
        'paymentIdentifier': paymentIdentifier,
        'email': email,
        'phoneNumber': phoneNumber,
        'customerId': customerId,
        'metadata': metadata,
      };
}
