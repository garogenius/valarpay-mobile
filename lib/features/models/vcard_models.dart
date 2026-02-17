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
  });

  factory VirtualCardModel.fromJson(Map<String, dynamic> json) {
    return VirtualCardModel(
      id: json['id'],
      walletId: json['walletId'],
      userId: json['userId'],
      cardNumber: json['cardNumber'],
      last4Digits: json['last4Digits'] ?? (json['cardNumber'] != null && json['cardNumber'].toString().length >= 4 ? json['cardNumber'].toString().substring(json['cardNumber'].toString().length - 4) : ''),
      cvv: json['cvv'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      cardholderName: json['cardholderName'] ?? '',
      currency: json['currency'],
      providerCardId: json['providerCardId'],
      providerType: json['providerType'],
      balance: (json['balance'] as num).toDouble(),
      status: json['status'],
      label: json['label'] ?? '',
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  bool get isFrozen => status.toUpperCase() == 'FROZEN';
  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isBlocked => status.toUpperCase() == 'BLOCKED';
}

class CreateCardRequest {
  final String currency;
  final String label;
  final double fundingAmount;
  final String pin;

  CreateCardRequest({
    required this.currency,
    required this.label,
    required this.fundingAmount,
    required this.pin,
  });

  Map<String, dynamic> toJson() => {
    'currency': currency,
    'label': label,
    'fundingAmount': fundingAmount,
    'pin': pin,
  };
}

class FundCardRequest {
  final String cardId;
  final double amount;
  final String walletPin;

  FundCardRequest({
    required this.cardId,
    required this.amount,
    required this.walletPin,
  });

  Map<String, dynamic> toJson() => {
    'cardId': cardId,
    'amount': amount,
    'walletPin': walletPin,
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
      id: json['id'],
      cardId: json['cardId'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      transactionType: json['transactionType'],
      status: json['status'],
      merchantName: json['merchantName'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
