class CurrencyConversionData {
  final double amount;
  final double convertedAmount;
  final double exchangeRate;
  final String fromCurrency;
  final String toCurrency;
  final String? timestamp;

  CurrencyConversionData({
    required this.amount,
    required this.convertedAmount,
    required this.exchangeRate,
    required this.fromCurrency,
    required this.toCurrency,
    this.timestamp,
  });

  factory CurrencyConversionData.fromJson(Map<String, dynamic> json) {
    return CurrencyConversionData(
      amount: (json['originalAmount'] ?? json['amount'] ?? 0.0).toDouble(),
      convertedAmount: (json['convertedAmount'] ?? 0.0).toDouble(),
      exchangeRate: (json['exchangeRate'] ?? 0.0).toDouble(),
      fromCurrency: json['fromCurrency'] ?? '',
      toCurrency: json['toCurrency'] ?? '',
      timestamp: json['timestamp'],
    );
  }

  @override
  String toString() {
    return 'CurrencyConversionData(amount: $amount, convertedAmount: $convertedAmount, exchangeRate: $exchangeRate, from: $fromCurrency, to: $toCurrency)';
  }
}

class CurrencyConversionResponse {
  final int statusCode;
  final CurrencyConversionData? data;
  final String? message;
  final List<String>? errors;

  CurrencyConversionResponse({
    required this.statusCode,
    this.data,
    this.message,
    this.errors,
  });

  factory CurrencyConversionResponse.fromJson(Map<String, dynamic> json) {
    // API might return the object directly or wrapped in 'data'
    final dataMap = json.containsKey('data') ? json['data'] : json;
    
    // Check if dataMap contains any of the expected conversion fields
    final hasData = dataMap is Map<String, dynamic> && 
                   (dataMap.containsKey('exchangeRate') || 
                    dataMap.containsKey('convertedAmount') ||
                    dataMap.containsKey('originalAmount'));
    
    return CurrencyConversionResponse(
      statusCode: json['statusCode'] ?? 200,
      data: hasData ? CurrencyConversionData.fromJson(dataMap as Map<String, dynamic>) : null,
      message: json['message'] is String ? json['message'] : null,
      errors: json['message'] is List ? List<String>.from(json['message']) : null,
    );
  }
}

class ExchangeRateResponse {
  final String fromCurrency;
  final String toCurrency;
  final double exchangeRate;
  final String timestamp;

  ExchangeRateResponse({
    required this.fromCurrency,
    required this.toCurrency,
    required this.exchangeRate,
    required this.timestamp,
  });

  factory ExchangeRateResponse.fromJson(Map<String, dynamic> json) {
    return ExchangeRateResponse(
      fromCurrency: json['fromCurrency'],
      toCurrency: json['toCurrency'],
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      timestamp: json['timestamp'],
    );
  }
}

class SupportedCurrency {
  final String code;
  final String name;
  final String symbol;
  final int decimalPlaces;

  SupportedCurrency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimalPlaces,
  });

  factory SupportedCurrency.fromJson(Map<String, dynamic> json) {
    return SupportedCurrency(
      code: json['code'],
      name: json['name'],
      symbol: json['symbol'],
      decimalPlaces: json['decimalPlaces'],
    );
  }
}

class SupportedCurrenciesResponse {
  final String message;
  final List<SupportedCurrency> currencies;
  final int count;

  SupportedCurrenciesResponse({
    required this.message,
    required this.currencies,
    required this.count,
  });

  factory SupportedCurrenciesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return SupportedCurrenciesResponse(
      message: json['message'],
      currencies: (data['currencies'] as List)
          .map((e) => SupportedCurrency.fromJson(e))
          .toList(),
      count: data['count'],
    );
  }
}
