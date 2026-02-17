class EducationBiller {
  final String billerId;
  final String billerName;
  final String? billerShortName;
  final String category;
  final String? countryCode;
  final String? billerLogoUrl;
  final String? description;

  EducationBiller({
    required this.billerId,
    required this.billerName,
    this.billerShortName,
    required this.category,
    this.countryCode,
    this.billerLogoUrl,
    this.description,
  });

  factory EducationBiller.fromJson(Map<String, dynamic> json) => EducationBiller(
        billerId: json['billerId'] ?? json['code'] ?? '',
        billerName: json['billerName'] ?? json['name'] ?? '',
        billerShortName: json['billerShortName'],
        category: json['category']?.toString() ?? 'exam',
        countryCode: json['countryCode'],
        billerLogoUrl: json['billerLogoUrl'] ?? json['logoUrl'],
        description: json['description'],
      );
}

class EducationProduct {
  final String id;
  final String name;
  final bool? isAmountFixed;
  final double amount;
  final String? currency;
  final double? payAmount;

  EducationProduct({
    required this.id,
    required this.name,
    this.isAmountFixed,
    required this.amount,
    this.currency,
    this.payAmount,
  });

  factory EducationProduct.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return EducationProduct(
      id: json['billPaymentProductId'] ?? 
          json['id']?.toString() ?? 
          json['variation_code'] ?? 
          json['variationCode'] ?? 
          json['service_id'] ?? 
          '',
      name: json['billPaymentProductName'] ?? 
            json['name'] ?? 
            json['variation_name'] ?? 
            json['variationName'] ?? 
            json['description'] ?? 
            '',
      isAmountFixed: json['isAmountFixed'],
      amount: parseDouble(json['amount'] ?? json['variation_amount'] ?? json['variationAmount'] ?? json['price']),
      currency: json['currency'],
      payAmount: parseDouble(json['payAmount'] ?? json['amount']),
    );
  }
}

class EducationVerificationResponse {
  final String customerName;
  final String billerNumber;
  final double amount;
  final String? registrationNumber;
  final String? candidateNumber;

  EducationVerificationResponse({
    required this.customerName,
    required this.billerNumber,
    required this.amount,
    this.registrationNumber,
    this.candidateNumber,
  });

  factory EducationVerificationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return EducationVerificationResponse(
      customerName: data['customerName'] ?? '',
      billerNumber: data['billerNumber'] ?? data['registrationNumber'] ?? data['candidateNumber'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      registrationNumber: data['registrationNumber'],
      candidateNumber: data['candidateNumber'],
    );
  }
}

class EducationPaymentRequest {
  final String itemCode;
  final String billerCode;
  final String currency;
  final String billerNumber;
  final double amount;
  final String walletPin;
  final bool addBeneficiary;

  EducationPaymentRequest({
    required this.itemCode,
    required this.billerCode,
    this.currency = 'NGN',
    required this.billerNumber,
    required this.amount,
    required this.walletPin,
    this.addBeneficiary = false,
  });

  Map<String, dynamic> toJson() => {
        'itemCode': itemCode,
        'billerCode': billerCode,
        'currency': currency,
        'billerNumber': billerNumber,
        'amount': amount,
        'walletPin': walletPin,
        'addBeneficiary': addBeneficiary,
      };
}

class EducationPaymentResponse {
  final String message;
  final String transactionRef;
  final double amount;
  final String billerCode;
  final String? studentNumber;
  final String? registrationNumber;
  final String? candidateNumber;

  EducationPaymentResponse({
    required this.message,
    required this.transactionRef,
    required this.amount,
    required this.billerCode,
    this.studentNumber,
    this.registrationNumber,
    this.candidateNumber,
  });

  factory EducationPaymentResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return EducationPaymentResponse(
      message: json['message'] ?? '',
      transactionRef: data['transactionRef'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      billerCode: data['billerCode'] ?? '',
      studentNumber: data['studentNumber'],
      registrationNumber: data['registrationNumber'],
      candidateNumber: data['candidateNumber'],
    );
  }
}
