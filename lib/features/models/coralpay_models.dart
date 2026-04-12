class CoralPayGroup {
  final int id;
  final String name;
  final String slug;
  final String? description;

  CoralPayGroup({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
  });

  factory CoralPayGroup.fromJson(Map<String, dynamic> json) => CoralPayGroup(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        name: json['name'] ?? '',
        slug: json['slug'] ?? '',
        description: json['description'],
      );
}

class CoralPayBiller {
  final dynamic id;
  final String name;
  final String slug;
  final String? logoUrl;

  CoralPayBiller({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
  });

  factory CoralPayBiller.fromJson(Map<String, dynamic> json) => CoralPayBiller(
        id: json['id'] ?? json['billerId'] ?? '',
        name: json['name'] ?? json['billerName'] ?? '',
        slug: json['slug'] ?? json['billerSlug'] ?? '',
        logoUrl: json['logoUrl'] ?? json['billerLogoUrl'],
      );
}

class CoralPayPackage {
  final dynamic id;
  final String name;
  final String slug;
  final double amount;
  final bool isAmountFixed;

  CoralPayPackage({
    required this.id,
    required this.name,
    required this.slug,
    required this.amount,
    required this.isAmountFixed,
  });

  factory CoralPayPackage.fromJson(Map<String, dynamic> json) => CoralPayPackage(
        id: json['id'] ?? '',
        name: json['name'] ?? json['packageName'] ?? '',
        slug: json['slug'] ?? json['packageSlug'] ?? '',
        amount: (json['amount'] ?? 0.0).toDouble(),
        isAmountFixed: json['isAmountFixed'] ?? false,
      );
}

class CoralPayCustomerVerification {
  final String customerName;
  final String? customerId;
  final String? billerSlug;
  final String? productName;
  final double? minAmount;

  CoralPayCustomerVerification({
    required this.customerName,
    this.customerId,
    this.billerSlug,
    this.productName,
    this.minAmount,
  });

  factory CoralPayCustomerVerification.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final customer = data['customer'] ?? {};
    
    return CoralPayCustomerVerification(
      customerName: customer['customerName'] ?? data['customerName'] ?? data['name'] ?? '',
      customerId: (customer['accountNumber'] ?? data['customerId'] ?? data['accountNumber'])?.toString(),
      billerSlug: data['billerSlug'],
      productName: data['productName'] ?? data['packageSlug'],
      minAmount: (data['minAmount'] ?? data['minimumAmount'] ?? 0.0).toDouble(),
    );
  }
}

class CoralPayPaymentRequest {
  final String customerId;
  final String billerSlug;
  final String packageSlug;
  final double amount;
  final String customerName;
  final String? walletPin;

  CoralPayPaymentRequest({
    required this.customerId,
    required this.billerSlug,
    required this.packageSlug,
    required this.amount,
    required this.customerName,
    this.walletPin,
  });

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'billerSlug': billerSlug,
        'packageSlug': packageSlug,
        'amount': amount,
        'customerName': customerName,
        if (walletPin != null) 'walletPin': walletPin,
      };
}

class CoralPayPaymentResponse {
  final bool success;
  final String message;
  final String? transactionId;
  final String? paymentReference;

  CoralPayPaymentResponse({
    required this.success,
    required this.message,
    this.transactionId,
    this.paymentReference,
  });

  factory CoralPayPaymentResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return CoralPayPaymentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      transactionId: data['transactionId']?.toString(),
      paymentReference: data['paymentReference']?.toString(),
    );
  }
}
