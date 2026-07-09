class WalletModel {
  final String id;
  final String userId;
  final double balance;
  final String currency;
  final String accountNumber;
  final String accountName;
  final String bankName;
  final String? bankCode;
  final String? accountRef;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.currency,
    required this.accountNumber,
    required this.accountName,
    required this.bankName,
    this.bankCode,
    this.accountRef,
    this.createdAt,
    this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      balance: (json['balance'] is int)
          ? (json['balance'] as int).toDouble()
          : (json['balance'] as double? ?? 0.0),
      currency: json['currency'] as String? ?? 'NGN',
      accountNumber: json['accountNumber'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
      bankName: json['bankName'] as String? ?? '',
      bankCode: json['bankCode'] as String?,
      accountRef: json['accountRef'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'balance': balance,
      'currency': currency,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'bankName': bankName,
      'bankCode': bankCode,
      'accountRef': accountRef,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper method to format balance with currency
  String get formattedBalance {
    return '${_getCurrencySymbol(currency)}${balance.toStringAsFixed(2)}';
  }

  String get symbol => _getCurrencySymbol(currency);

  static String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'XAF':
        return 'FCFA ';
      case 'TZS':
        return 'TSh ';
      case 'KES':
        return 'KSh ';
      case 'GHS':
        return 'GH₵ ';
      case 'UGX':
        return 'USh ';
      case 'ZAR':
        return 'R ';
      case 'XOF':
        return 'CFA ';
      default:
        return '$currencyCode ';
    }
  }

  // Helper to get masked account number (e.g., "****7890")
  String get maskedAccountNumber {
    if (accountNumber.length >= 4) {
      return '*' * (accountNumber.length - 4) +
          accountNumber.substring(accountNumber.length - 4);
    }
    return accountNumber;
  }

  // Copy with method for updates
  WalletModel copyWith({
    String? id,
    String? userId,
    double? balance,
    String? currency,
    String? accountNumber,
    String? accountName,
    String? bankName,
    String? bankCode,
    String? accountRef,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      bankName: bankName ?? this.bankName,
      bankCode: bankCode ?? this.bankCode,
      accountRef: accountRef ?? this.accountRef,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
