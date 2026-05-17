class VirtualCardModel {
  final String id;
  final String walletId;
  final String? userId;
  final String cardNumber;
  final String last4Digits;
  final String cvv;
  final String expiryMonth;
  final String expiryYear;
  final String cardholderName;
  final String currency;
  final String? providerCardId;
  final String? providerType;
  final double balance;
  final String status;
  final String label;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String color;

  VirtualCardModel({
    required this.id,
    required this.walletId,
    this.userId,
    required this.cardNumber,
    required this.last4Digits,
    required this.cvv,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardholderName,
    required this.currency,
    this.providerCardId,
    this.providerType,
    required this.balance,
    required this.status,
    required this.label,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.color = 'Midnight Executive',
  });

  factory VirtualCardModel.fromJson(Map<String, dynamic> json) {
    // Handle both direct and nested data structures
    final data = json['data'] ?? json;
    
    return VirtualCardModel(
      id: data['id']?.toString() ?? '',
      walletId: data['walletId']?.toString() ?? '',
      userId: data['userId']?.toString(),
      cardNumber: data['cardNumber']?.toString() ?? '',
      last4Digits: data['last4Digits']?.toString() ?? (data['cardNumber'] != null && data['cardNumber'].toString().length >= 4 ? data['cardNumber'].toString().substring(data['cardNumber'].toString().length - 4) : ''),
      cvv: data['cvv']?.toString() ?? '',
      expiryMonth: data['expiryMonth']?.toString() ?? '',
      expiryYear: data['expiryYear']?.toString() ?? '',
      cardholderName: data['cardholderName']?.toString() ?? '',
      currency: data['currency']?.toString() ?? 'USD',
      providerCardId: data['providerCardId']?.toString(),
      providerType: data['providerType']?.toString(),
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      status: data['status']?.toString() ?? 'ACTIVE',
      label: data['label']?.toString() ?? data['title']?.toString() ?? '',
      metadata: data['metadata'],
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : DateTime.now(),
      color: data['color']?.toString() ?? 'Midnight Executive',
    );
  }

  bool get isFrozen => status.toUpperCase() == 'FROZEN' || status.toUpperCase() == 'INACTIVE';
  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isBlocked => status.toUpperCase() == 'BLOCKED' || status.toUpperCase() == 'TERMINATED';
}

class EversendCreateCardRequest {
  final String walletId;
  final EversendUserData userData;
  final EversendCardData cardData;

  EversendCreateCardRequest({
    required this.walletId,
    required this.userData,
    required this.cardData,
  });

  Map<String, dynamic> toJson() => {
    'walletId': walletId,
    'userData': userData.toJson(),
    'cardData': cardData.toJson(),
  };
}

class EversendUserData {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String country;
  final String state;
  final String city;
  final String address;
  final String zipCode;
  final String idType;
  final String idNumber;

  EversendUserData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.country,
    required this.state,
    required this.city,
    required this.address,
    required this.zipCode,
    required this.idType,
    required this.idNumber,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'country': country,
    'state': state,
    'city': city,
    'address': address,
    'zipCode': zipCode,
    'idType': idType,
    'idNumber': idNumber,
  };
}

class EversendCardData {
  final String userId;
  final String title;
  final String amount;
  final String currency;
  final String brand;
  final String color;
  final bool isNonSubscription;

  EversendCardData({
    required this.userId,
    required this.title,
    required this.amount,
    required this.currency,
    this.brand = 'VISA',
    this.color = '#FFFFFF',
    this.isNonSubscription = false,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'title': title,
    'amount': amount,
    'currency': currency,
    'brand': brand,
    'color': color,
    'isNonSubscription': isNonSubscription,
  };
}

class CreateCardRequest {
  final String currency;
  final String label;
  final double fundingAmount;
  final String color;

  CreateCardRequest({
    required this.currency,
    required this.label,
    required this.fundingAmount,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'currency': currency,
    'label': label,
    'fundingAmount': fundingAmount,
    'color': color,
  };
}

class FundCardRequest {
  final String cardId;
  final double amount;
  final String? walletPin;

  FundCardRequest({
    required this.cardId,
    required this.amount,
    this.walletPin,
  });

  Map<String, dynamic> toJson() => {
    'cardId': cardId,
    'amount': amount,
    if (walletPin != null) 'walletPin': walletPin,
  };
}

class CardTransactionModel {
  final String id;
  final String cardId;
  final double amount;
  final String currency;
  final String transactionType;
  final String status;
  final String merchantName;
  final String description;
  final DateTime timestamp;

  CardTransactionModel({
    required this.id,
    required this.cardId,
    required this.amount,
    required this.currency,
    required this.transactionType,
    required this.status,
    required this.merchantName,
    required this.description,
    required this.timestamp,
  });

  factory CardTransactionModel.fromJson(Map<String, dynamic> json) {
    return CardTransactionModel(
      id: json['id']?.toString() ?? '',
      cardId: json['cardId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      transactionType: json['transactionType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      merchantName: json['merchantName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
    );
  }
}
