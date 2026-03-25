import 'dart:convert';

class CardProviders {
  final String defaultProvider;
  final List<String> available;

  CardProviders({required this.defaultProvider, required this.available});

  factory CardProviders.fromJson(Map<String, dynamic> json) => CardProviders(
        defaultProvider: json['default'] ?? 'flutterwave',
        available: List<String>.from(json['available'] ?? []),
      );
}

class CardLinkInitiateRequest {
  final String? provider;
  final int amountMinor;
  final String currency;

  CardLinkInitiateRequest({
    this.provider,
    required this.amountMinor,
    this.currency = 'NGN',
  });

  Map<String, dynamic> toJson() => {
        if (provider != null) 'provider': provider,
        'amountMinor': amountMinor,
        'currency': currency,
      };
}

class CardLinkInitiateResponse {
  final String attemptId;
  final String txRef;
  final String redirectUrl;
  final String? sessionId;
  final String provider;

  CardLinkInitiateResponse({
    required this.attemptId,
    required this.txRef,
    required this.redirectUrl,
    this.sessionId,
    required this.provider,
  });

  factory CardLinkInitiateResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return CardLinkInitiateResponse(
      attemptId: data['attemptId']?.toString() ?? '',
      txRef: data['txRef']?.toString() ?? data['tx_ref']?.toString() ?? '',
      redirectUrl: data['redirectUrl']?.toString() ?? data['link']?.toString() ?? data['meta']?['authorization']?['redirect']?.toString() ?? data['authorization_url']?.toString() ?? '',
      sessionId: data['sessionId']?.toString() ?? data['session_id']?.toString(),
      provider: data['provider']?.toString() ?? '',
    );
  }
}

class LinkedCard {
  final String id;
  final String provider;
  final String cardBrand;
  final String cardLast4;
  final int cardExpMonth;
  final int cardExpYear;
  final String cardCountry;
  final String status;
  final DateTime createdAt;

  LinkedCard({
    required this.id,
    required this.provider,
    required this.cardBrand,
    required this.cardLast4,
    required this.cardExpMonth,
    required this.cardExpYear,
    required this.cardCountry,
    required this.status,
    required this.createdAt,
  });

  factory LinkedCard.fromJson(Map<String, dynamic> json) => LinkedCard(
        id: json['id']?.toString() ?? '',
        provider: json['provider']?.toString() ?? '',
        cardBrand: json['cardBrand'] ?? json['brand'] ?? '',
        cardLast4: json['cardLast4'] ?? json['last_4digits'] ?? json['last4'] ?? '',
        cardExpMonth: int.tryParse(json['cardExpMonth']?.toString() ?? json['exp_month']?.toString() ?? '') ?? 0,
        cardExpYear: int.tryParse(json['cardExpYear']?.toString() ?? json['exp_year']?.toString() ?? '') ?? 0,
        cardCountry: json['cardCountry'] ?? json['country'] ?? '',
        status: json['status']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );
}

class ChargeCardRequest {
  final int amountMinor;
  final String currency;
  final String? txRef;

  ChargeCardRequest({
    required this.amountMinor,
    this.currency = 'NGN',
    this.txRef,
  });

  Map<String, dynamic> toJson() => {
        'amountMinor': amountMinor,
        'currency': currency,
        if (txRef != null) 'txRef': txRef,
      };
}

class ChargeCardResponse {
  final String providerTransactionId;
  final String txRef;
  final String status;
  final int amountMinor;
  final String currency;

  ChargeCardResponse({
    required this.providerTransactionId,
    required this.txRef,
    required this.status,
    required this.amountMinor,
    required this.currency,
  });

  factory ChargeCardResponse.fromJson(Map<String, dynamic> json) =>
      ChargeCardResponse(
        providerTransactionId: json['providerTransactionId'] ?? '',
        txRef: json['txRef'] ?? '',
        status: json['status'] ?? '',
        amountMinor: json['amountMinor'] ?? 0,
        currency: json['currency'] ?? '',
      );
}
