class GiftCardCategory {
  final int id;
  final String name;

  GiftCardCategory({required this.id, required this.name});

  factory GiftCardCategory.fromJson(Map<String, dynamic> json) {
    return GiftCardCategory(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class GiftCardBrand {
  final int brandId;
  final String brandName;

  GiftCardBrand({required this.brandId, required this.brandName});

  factory GiftCardBrand.fromJson(Map<String, dynamic> json) {
    return GiftCardBrand(
      brandId: json['brandId'] ?? 0,
      brandName: json['brandName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'brandId': brandId, 'brandName': brandName};
  }
}

class GiftCardCountry {
  final String isoName;
  final String name;
  final String flagUrl;

  GiftCardCountry({
    required this.isoName,
    required this.name,
    required this.flagUrl,
  });

  factory GiftCardCountry.fromJson(Map<String, dynamic> json) {
    return GiftCardCountry(
      isoName: json['isoName'] ?? '',
      name: json['name'] ?? '',
      flagUrl: json['flagUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'isoName': isoName, 'name': name, 'flagUrl': flagUrl};
  }
}

class RedeemInstruction {
  final String concise;
  final String verbose;

  RedeemInstruction({required this.concise, required this.verbose});

  factory RedeemInstruction.fromJson(Map<String, dynamic> json) {
    return RedeemInstruction(
      concise: json['concise'] ?? '',
      verbose: json['verbose'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'concise': concise, 'verbose': verbose};
  }
}

class AdditionalRequirements {
  final bool userIdRequired;

  AdditionalRequirements({required this.userIdRequired});

  factory AdditionalRequirements.fromJson(Map<String, dynamic> json) {
    return AdditionalRequirements(
      userIdRequired: json['userIdRequired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'userIdRequired': userIdRequired};
  }
}

class GiftCardProduct {
  final int productId;
  final String productName;
  final bool global;
  final String status;
  final bool supportsPreOrder;
  final double senderFee;
  final double senderFeePercentage;
  final double discountPercentage;
  final String denominationType;
  final String recipientCurrencyCode;
  final double? minRecipientDenomination;
  final double? maxRecipientDenomination;
  final String senderCurrencyCode;
  final double? minSenderDenomination;
  final double? maxSenderDenomination;
  final List<double> fixedRecipientDenominations;
  final List<double>? fixedSenderDenominations;
  final Map<String, double>? fixedRecipientToSenderDenominationsMap;
  final Map<String, String>? metadata;
  final List<String> logoUrls;
  final GiftCardBrand brand;
  final GiftCardCategory category;
  final GiftCardCountry country;
  final RedeemInstruction redeemInstruction;
  final AdditionalRequirements additionalRequirements;
  final Map<String, double>? fixedRecipientToPayAmount;

  GiftCardProduct({
    required this.productId,
    required this.productName,
    required this.global,
    required this.status,
    required this.supportsPreOrder,
    required this.senderFee,
    required this.senderFeePercentage,
    required this.discountPercentage,
    required this.denominationType,
    required this.recipientCurrencyCode,
    this.minRecipientDenomination,
    this.maxRecipientDenomination,
    required this.senderCurrencyCode,
    this.minSenderDenomination,
    this.maxSenderDenomination,
    required this.fixedRecipientDenominations,
    this.fixedSenderDenominations,
    this.fixedRecipientToSenderDenominationsMap,
    this.metadata,
    required this.logoUrls,
    required this.brand,
    required this.category,
    required this.country,
    required this.redeemInstruction,
    required this.additionalRequirements,
    this.fixedRecipientToPayAmount,
  });

  factory GiftCardProduct.fromJson(Map<String, dynamic> json) {
    return GiftCardProduct(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      global: json['global'] ?? false,
      status: json['status'] ?? '',
      supportsPreOrder: json['supportsPreOrder'] ?? false,
      senderFee: (json['senderFee'] ?? 0).toDouble(),
      senderFeePercentage: (json['senderFeePercentage'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      denominationType: json['denominationType'] ?? '',
      recipientCurrencyCode: json['recipientCurrencyCode'] ?? '',
      minRecipientDenomination: json['minRecipientDenomination']?.toDouble(),
      maxRecipientDenomination: json['maxRecipientDenomination']?.toDouble(),
      senderCurrencyCode: json['senderCurrencyCode'] ?? '',
      minSenderDenomination: json['minSenderDenomination']?.toDouble(),
      maxSenderDenomination: json['maxSenderDenomination']?.toDouble(),
      fixedRecipientDenominations:
          (json['fixedRecipientDenominations'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      fixedSenderDenominations:
          (json['fixedSenderDenominations'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList(),
      fixedRecipientToSenderDenominationsMap:
          (json['fixedRecipientToSenderDenominationsMap']
                  as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, (value as num).toDouble())),
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
      logoUrls: (json['logoUrls'] as List?)?.cast<String>() ?? [],
      brand: GiftCardBrand.fromJson(json['brand'] ?? {}),
      category: GiftCardCategory.fromJson(json['category'] ?? {}),
      country: GiftCardCountry.fromJson(json['country'] ?? {}),
      redeemInstruction: RedeemInstruction.fromJson(
        json['redeemInstruction'] ?? {},
      ),
      additionalRequirements: AdditionalRequirements.fromJson(
        json['additionalRequirements'] ?? {},
      ),
      fixedRecipientToPayAmount: (json['fixedRecipientToPayAmount']
              as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, (value as num).toDouble())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'global': global,
      'status': status,
      'supportsPreOrder': supportsPreOrder,
      'senderFee': senderFee,
      'senderFeePercentage': senderFeePercentage,
      'discountPercentage': discountPercentage,
      'denominationType': denominationType,
      'recipientCurrencyCode': recipientCurrencyCode,
      'minRecipientDenomination': minRecipientDenomination,
      'maxRecipientDenomination': maxRecipientDenomination,
      'senderCurrencyCode': senderCurrencyCode,
      'minSenderDenomination': minSenderDenomination,
      'maxSenderDenomination': maxSenderDenomination,
      'fixedRecipientDenominations': fixedRecipientDenominations,
      'fixedSenderDenominations': fixedSenderDenominations,
      'fixedRecipientToSenderDenominationsMap':
          fixedRecipientToSenderDenominationsMap,
      'metadata': metadata,
      'logoUrls': logoUrls,
      'brand': brand.toJson(),
      'category': category.toJson(),
      'country': country.toJson(),
      'redeemInstruction': redeemInstruction.toJson(),
      'additionalRequirements': additionalRequirements.toJson(),
      'fixedRecipientToPayAmount': fixedRecipientToPayAmount,
    };
  }
}

class GiftCardProductResponse {
  final String message;
  final int statusCode;
  final List<GiftCardProduct> data;

  GiftCardProductResponse({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory GiftCardProductResponse.fromJson(Map<String, dynamic> json) {
    return GiftCardProductResponse(
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data:
          (json['data'] as List?)
              ?.map((item) => GiftCardProduct.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class GiftCardPaymentRequest {
  final int productId;
  final String currency;
  final String walletPin;
  final double amount;
  final double unitPrice;
  final int quantity;

  GiftCardPaymentRequest({
    required this.productId,
    required this.currency,
    required this.walletPin,
    required this.amount,
    required this.unitPrice,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'currency': currency,
      'walletPin': walletPin,
      'amount': amount,
      'unitPrice': unitPrice,
      'quantity': quantity,
    };
  }
}

class GiftCardFxRateResponse {
  final String message;
  final int statusCode;
  final GiftCardFxRateData data;

  GiftCardFxRateResponse({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory GiftCardFxRateResponse.fromJson(Map<String, dynamic> json) {
    return GiftCardFxRateResponse(
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: GiftCardFxRateData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': data.toJson(),
    };
  }
}

class GiftCardFxRateData {
  final String senderCurrency;
  final double senderAmount;
  final String recipientCurrency;
  final double recipientAmount;

  GiftCardFxRateData({
    required this.senderCurrency,
    required this.senderAmount,
    required this.recipientCurrency,
    required this.recipientAmount,
  });

  factory GiftCardFxRateData.fromJson(Map<String, dynamic> json) {
    return GiftCardFxRateData(
      senderCurrency: json['senderCurrency'] ?? '',
      senderAmount: (json['senderAmount'] ?? 0).toDouble(),
      recipientCurrency: json['recipientCurrency'] ?? '',
      recipientAmount: (json['recipientAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderCurrency': senderCurrency,
      'senderAmount': senderAmount,
      'recipientCurrency': recipientCurrency,
      'recipientAmount': recipientAmount,
    };
  }
}

class GiftCardRedeemCodeResponse {
  final String message;
  final int statusCode;
  final String? redeemCode;

  GiftCardRedeemCodeResponse({
    required this.message,
    required this.statusCode,
    this.redeemCode,
  });

  factory GiftCardRedeemCodeResponse.fromJson(Map<String, dynamic> json) {
    return GiftCardRedeemCodeResponse(
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      redeemCode: json['redeemCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'redeemCode': redeemCode,
    };
  }
}

// Giftcard Beneficiary Models
class GiftcardBeneficiary {
  final String id;
  final String cardNumber;
  final String? brandName;
  final String? productName;
  final String? recipientEmail;
  final String currency;
  final String userId;
  final String type;
  final String billType;

  GiftcardBeneficiary({
    required this.id,
    required this.cardNumber,
    this.brandName,
    this.productName,
    this.recipientEmail,
    required this.currency,
    required this.userId,
    required this.type,
    required this.billType,
  });

  factory GiftcardBeneficiary.fromJson(
    Map<String, dynamic> json,
  ) => GiftcardBeneficiary(
    id: json['id']?.toString() ?? '',
    cardNumber:
        json['card_number'] ?? json['cardNumber'] ?? json['billerNumber'] ?? '',
    brandName: json['brand_name'] ?? json['brandName'],
    productName: json['product_name'] ?? json['productName'],
    recipientEmail: json['recipient_email'] ?? json['recipientEmail'],
    currency: json['currency']?.toString() ?? 'NGN',
    userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
    type: json['type']?.toString() ?? 'GIFTCARD',
    billType: json['bill_type']?.toString() ?? json['billType'] ?? 'giftcard',
  );

  @override
  String toString() =>
      'GiftcardBeneficiary(id: $id, cardNumber: $cardNumber, brandName: $brandName)';
}

class GiftcardBeneficiariesResponse {
  final List<GiftcardBeneficiary> data;
  final String message;
  final int statusCode;
  final bool success;

  GiftcardBeneficiariesResponse({
    required this.data,
    required this.message,
    required this.statusCode,
    required this.success,
  });

  factory GiftcardBeneficiariesResponse.fromJson(Map<String, dynamic> json) {
    final list = <GiftcardBeneficiary>[];
    if (json['data'] != null && json['data'] is List) {
      list.addAll(
        (json['data'] as List).map(
          (e) => GiftcardBeneficiary.fromJson(e as Map<String, dynamic>),
        ),
      );
    }
    return GiftcardBeneficiariesResponse(
      data: list,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
      success: json['success'] ?? true,
    );
  }
}
