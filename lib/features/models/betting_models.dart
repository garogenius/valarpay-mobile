class BettingPlatformModel {
  final String code;
  final String name;
  final String description;
  final bool isActive;
  final String category;
  final num minAmount;
  final num maxAmount;
  final String logoUrl;

  BettingPlatformModel({
    required this.code,
    required this.name,
    required this.description,
    required this.isActive,
    required this.category,
    required this.minAmount,
    required this.maxAmount,
    required this.logoUrl,
  });

  factory BettingPlatformModel.fromJson(Map<String, dynamic> json) {
    return BettingPlatformModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? false,
      category: json['category'] ?? '',
      minAmount: json['minAmount'] ?? 0,
      maxAmount: json['maxAmount'] ?? 0,
      logoUrl: json['icon'] ?? json['logoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'isActive': isActive,
      'category': category,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'logoUrl': logoUrl,
      'icon': logoUrl,
    };
  }
}

class BettingPayRequest {
  final String platform;
  final String platformUserId;
  final num amount;
  final String currency;
  final String walletPin;
  final String description;
  final bool addBeneficiary;

  BettingPayRequest({
    required this.platform,
    required this.platformUserId,
    required this.amount,
    this.currency = 'NGN',
    required this.walletPin,
    required this.description,
    this.addBeneficiary = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'platformUserId': platformUserId,
      'amount': amount,
      'currency': currency,
      'walletPin': walletPin,
      'description': description,
      'addBeneficiary': addBeneficiary,
    };
  }
}

class BettingPayResponse {
  final String transactionRef;
  final String orderRef;
  final num amount;
  final String platform;
  final String platformUserId;
  final String status;

  BettingPayResponse({
    required this.transactionRef,
    required this.orderRef,
    required this.amount,
    required this.platform,
    required this.platformUserId,
    required this.status,
  });

  factory BettingPayResponse.fromJson(Map<String, dynamic> json) {
    return BettingPayResponse(
      transactionRef: json['transactionRef'] ?? '',
      orderRef: json['orderRef'] ?? '',
      amount: json['amount'] ?? 0,
      platform: json['platform'] ?? '',
      platformUserId: json['platformUserId'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
