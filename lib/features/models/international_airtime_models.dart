class InternationalCountry {
  final int id;
  final String name;
  final String isoCode;
  final String flag;

  InternationalCountry({
    required this.id,
    required this.name,
    required this.isoCode,
    required this.flag,
  });

  factory InternationalCountry.fromJson(Map<String, dynamic> json) => InternationalCountry(
        id: json['id'] ?? 0,
        name: json['name'] ?? json['countryName'] ?? '',
        isoCode: json['isoCode'] ?? json['countryCode'] ?? json['code'] ?? json['iso_code'] ?? '',
        flag: json['flag'] ?? '',
      );
}

class InternationalOperator {
  final int id;
  final String name;
  final String countryIsoCode;

  InternationalOperator({
    required this.id,
    required this.name,
    required this.countryIsoCode,
  });

  factory InternationalOperator.fromJson(Map<String, dynamic> json) => InternationalOperator(
        id: json['id'] ?? json['operatorId'] ?? 0,
        name: json['name'] ?? json['operatorName'] ?? '',
        countryIsoCode: json['countryIsoCode'] ?? json['countryCode'] ?? '',
      );
}

class InternationalAirtimePlan {
  final int operatorId;
  final String operatorName;
  final double payAmount;
  final List<double> fixedAmounts;
  final double minAmount;
  final double maxAmount;
  final String? logoUrl;
  final double fxRate;
  final String currencyCode;

  InternationalAirtimePlan({
    required this.operatorId,
    required this.operatorName,
    required this.payAmount,
    this.fixedAmounts = const [],
    this.minAmount = 0.0,
    this.maxAmount = 0.0,
    this.logoUrl,
    this.fxRate = 0.0,
    this.currencyCode = '',
  });

  factory InternationalAirtimePlan.fromJson(Map<String, dynamic> json) {
      String? logo;
      if (json['logoUrls'] != null && (json['logoUrls'] as List).isNotEmpty) {
          logo = (json['logoUrls'] as List).first;
      }
      
      double rate = 0.0;
      String currency = '';
      if (json['fx'] != null) {
          rate = (json['fx']['rate'] ?? 0.0).toDouble();
          currency = json['fx']['currencyCode'] ?? '';
      }

      return InternationalAirtimePlan(
        operatorId: json['operatorId'] ?? 0,
        operatorName: json['name'] ?? json['operatorName'] ?? '',
        payAmount: (json['payAmount'] ?? 0.0).toDouble(),
        fixedAmounts: (json['fixedAmounts'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
        minAmount: (json['minAmount'] ?? 0.0).toDouble(),
        maxAmount: (json['maxAmount'] ?? 0.0).toDouble(),
        logoUrl: logo,
        fxRate: rate,
        currencyCode: currency,
      );
  }
}

class InternationalFxRate {
  final double rate;
  final double amount;
  final double convertedAmount;
  final String fromCurrency;
  final String toCurrency;

  InternationalFxRate({
    required this.rate,
    required this.amount,
    required this.convertedAmount,
    required this.fromCurrency,
    required this.toCurrency,
  });

  factory InternationalFxRate.fromJson(Map<String, dynamic> json) {
      double amount = (json['amount'] ?? 0.0).toDouble();
      // API 'fxRate' or 'exchangeRate' is actually the exchange rate (e.g. 1 USD = 1500 NGN)
      double rate = (json['exchangeRate'] ?? json['fxRate'] ?? json['rate'] ?? 0.0).toDouble();
      
      // Calculate total converted amount (NGN)
      double convertedAmount = (json['convertedAmount'] ?? 0.0).toDouble();
      if (convertedAmount <= 0 && rate > 0 && amount > 0) {
          convertedAmount = amount * rate;
      }
      
      return InternationalFxRate(
        rate: rate,
        amount: amount,
        convertedAmount: convertedAmount,
        fromCurrency: json['currencyCode'] ?? json['fromCurrency'] ?? '',
        toCurrency: 'NGN', 
      );
  }
}

class InternationalAirtimePurchaseRequest {
  final double amount;
  final int operatorId;
  final String phone;
  final String currency;
  final String walletPin;
  final bool addBeneficiary;

  InternationalAirtimePurchaseRequest({
    required this.amount,
    required this.operatorId,
    required this.phone,
    required this.currency,
    required this.walletPin,
    required this.addBeneficiary,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'operatorId': operatorId,
        'phone': phone,
        'currency': currency,
        'walletPin': walletPin,
        'addBeneficiary': addBeneficiary,
      };
}

class InternationalAirtimePurchaseResponse {
  final String message;
  final String transactionRef;
  final double amount;
  final String currency;
  final String recipient;
  final String operator;

  InternationalAirtimePurchaseResponse({
    required this.message,
    required this.transactionRef,
    required this.amount,
    required this.currency,
    required this.recipient,
    required this.operator,
  });

  factory InternationalAirtimePurchaseResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return InternationalAirtimePurchaseResponse(
      message: json['message'] ?? '',
      transactionRef: data['transactionRef'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? '',
      recipient: data['recipient'] ?? '',
      operator: data['operator'] ?? '',
    );
  }
}

class InternationalAirtimeBalance {
  final double balance;
  final String currency;

  InternationalAirtimeBalance({
    required this.balance,
    required this.currency,
  });

  factory InternationalAirtimeBalance.fromJson(Map<String, dynamic> json) => InternationalAirtimeBalance(
        balance: (json['balance'] ?? 0.0).toDouble(),
        currency: json['currency'] ?? '',
      );
}
