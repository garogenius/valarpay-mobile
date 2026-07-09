class GiftCardCategory {
  final int id;
  final String name;

  GiftCardCategory({required this.id, required this.name});

  factory GiftCardCategory.fromJson(dynamic json) {
    if (json is Map) {
      return GiftCardCategory(
        id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
        name: json['name']?.toString() ?? json['category']?.toString() ?? '',
      );
    }
    return GiftCardCategory(
      id: 0,
      name: json?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class GiftCardBrand {
  final int brandId;
  final String brandName;

  GiftCardBrand({required this.brandId, required this.brandName});

  factory GiftCardBrand.fromJson(dynamic json) {
    if (json is Map) {
      return GiftCardBrand(
        brandId: json['brandId'] is int ? json['brandId'] : (int.tryParse(json['brandId']?.toString() ?? '') ?? 0),
        brandName: json['brandName']?.toString() ?? json['name']?.toString() ?? json['brand']?.toString() ?? '',
      );
    }
    return GiftCardBrand(
      brandId: 0,
      brandName: json?.toString() ?? '',
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

  factory GiftCardCountry.fromJson(dynamic json) {
    if (json is Map) {
      return GiftCardCountry(
        isoName: json['isoName']?.toString() ?? json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? json['countryName']?.toString() ?? '',
        flagUrl: json['flagUrl']?.toString() ?? json['flag']?.toString() ?? json['image']?.toString() ?? '',
      );
    }
    return GiftCardCountry(
      isoName: '',
      name: json?.toString() ?? '',
      flagUrl: '',
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

  factory RedeemInstruction.fromJson(dynamic json) {
    if (json is Map) {
      return RedeemInstruction(
        concise: json['concise']?.toString() ?? '',
        verbose: json['verbose']?.toString() ?? '',
      );
    }
    return RedeemInstruction(
      concise: '',
      verbose: json?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'concise': concise, 'verbose': verbose};
  }
}

class AdditionalRequirements {
  final bool userIdRequired;

  AdditionalRequirements({required this.userIdRequired});

  factory AdditionalRequirements.fromJson(dynamic json) {
    if (json is Map) {
      return AdditionalRequirements(
        userIdRequired: json['userIdRequired'] == true || json['userIdRequired']?.toString() == 'true',
      );
    }
    return AdditionalRequirements(userIdRequired: false);
  }

  Map<String, dynamic> toJson() {
    return {'userIdRequired': userIdRequired};
  }
}

class GiftCardProduct {
  final String productId;
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
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return GiftCardProduct(
      productId: json['productId']?.toString() ?? json['id']?.toString() ?? json['identifier']?.toString() ?? '',
      productName: json['productName'] ?? '',
      global: json['global'] ?? false,
      status: json['status'] ?? '',
      supportsPreOrder: json['supportsPreOrder'] ?? false,
      senderFee: parseDouble(json['senderFee']),
      senderFeePercentage: parseDouble(json['senderFeePercentage']),
      discountPercentage: parseDouble(json['discountPercentage']),
      denominationType: json['denominationType'] ?? '',
      recipientCurrencyCode: json['recipientCurrencyCode'] ?? '',
      minRecipientDenomination: json['minRecipientDenomination'] != null ? parseDouble(json['minRecipientDenomination']) : null,
      maxRecipientDenomination: json['maxRecipientDenomination'] != null ? parseDouble(json['maxRecipientDenomination']) : null,
      senderCurrencyCode: json['senderCurrencyCode'] ?? '',
      minSenderDenomination: json['minSenderDenomination'] != null ? parseDouble(json['minSenderDenomination']) : null,
      maxSenderDenomination: json['maxSenderDenomination'] != null ? parseDouble(json['maxSenderDenomination']) : null,
      fixedRecipientDenominations: json['fixedRecipientDenominations'] is List
          ? (json['fixedRecipientDenominations'] as List).map((e) => parseDouble(e)).toList()
          : [],
      fixedSenderDenominations: json['fixedSenderDenominations'] is List
          ? (json['fixedSenderDenominations'] as List).map((e) => parseDouble(e)).toList()
          : null,
      fixedRecipientToSenderDenominationsMap: json['fixedRecipientToSenderDenominationsMap'] is Map
          ? (json['fixedRecipientToSenderDenominationsMap'] as Map).map((key, value) => MapEntry(key.toString(), parseDouble(value)))
          : null,
      metadata: json['metadata'] is Map
          ? (json['metadata'] as Map).map((key, value) => MapEntry(key.toString(), value.toString()))
          : null,
      logoUrls: json['logoUrls'] is List
          ? (json['logoUrls'] as List).map((e) => e.toString()).toList()
          : [],
      brand: GiftCardBrand.fromJson(json['brand'] ?? {}),
      category: GiftCardCategory.fromJson(json['category'] ?? {}),
      country: GiftCardCountry.fromJson(json['country'] ?? {}),
      redeemInstruction: RedeemInstruction.fromJson(json['redeemInstruction'] ?? {}),
      additionalRequirements: AdditionalRequirements.fromJson(json['additionalRequirements'] ?? {}),
      fixedRecipientToPayAmount: json['fixedRecipientToPayAmount'] is Map
          ? (json['fixedRecipientToPayAmount'] as Map).map((key, value) => MapEntry(key.toString(), parseDouble(value)))
          : null,
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
    final List<GiftCardProduct> products = [];
    
    dynamic rawList;
    if (json['data'] is List) {
      rawList = json['data'];
    } else if (json['data'] is Map) {
      final Map<String, dynamic> dataMap = json['data'];
      rawList = dataMap['products'] ?? dataMap['content'] ?? dataMap['items'] ?? dataMap['giftcards'] ?? dataMap['data'];
    }
    
    rawList ??= json['products'] ?? json['content'] ?? json['items'] ?? json['giftcards'];
    
    if (rawList == null && json is List) {
      rawList = json;
    }
    
    rawList ??= [json];

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    if (rawList is List) {
      for (var item in rawList) {
        if (item is Map) {
          final mapItem = Map<String, dynamic>.from(item);
          if (mapItem['package'] != null) {
            // New package format
            final packageImage = mapItem['image']?.toString() ?? '';
            final packageName = mapItem['package']?.toString() ?? '';
            final categoryName = mapItem['category']?.toString() ?? '';
            final countriesList = mapItem['countries'];
            if (countriesList is List) {
              for (var countryObj in countriesList) {
                if (countryObj is Map) {
                  final countryMap = Map<String, dynamic>.from(countryObj);
                  final countryName = countryMap['name']?.toString() ?? '';
                  final countryImage = countryMap['image']?.toString() ?? '';
                  final countryPkgName = countryMap['packageName']?.toString() ?? packageName;
                  final countryCurrency = countryMap['currency']?.toString() ?? '';
                  final itemsList = countryMap['items'];
                  if (itemsList is List) {
                    for (var itemObj in itemsList) {
                      if (itemObj is Map) {
                        final itemMap = Map<String, dynamic>.from(itemObj);
                        final identifier = itemMap['identifier']?.toString() ?? '';
                        final double minVal = parseDouble(itemMap['localProductValueMin'] ?? itemMap['minRecipientDenomination']);
                        final double maxVal = parseDouble(itemMap['localProductValueMax'] ?? itemMap['maxRecipientDenomination']);
                        final isRange = minVal != maxVal;

                        final product = GiftCardProduct(
                          productId: identifier,
                          productName: countryPkgName,
                          global: false,
                          status: 'ACTIVE',
                          supportsPreOrder: false,
                          senderFee: 0.0,
                          senderFeePercentage: 0.0,
                          discountPercentage: 0.0,
                          denominationType: isRange ? 'RANGE' : 'FIXED',
                          recipientCurrencyCode: countryCurrency,
                          minRecipientDenomination: minVal,
                          maxRecipientDenomination: maxVal,
                          senderCurrencyCode: countryCurrency,
                          minSenderDenomination: minVal,
                          maxSenderDenomination: maxVal,
                          fixedRecipientDenominations: isRange ? [] : [minVal],
                          logoUrls: packageImage.isNotEmpty ? [packageImage] : [],
                          brand: GiftCardBrand(brandId: 0, brandName: packageName),
                          category: GiftCardCategory(id: 0, name: categoryName),
                          country: GiftCardCountry(
                            isoName: countryName,
                            name: countryName,
                            flagUrl: countryImage,
                          ),
                          redeemInstruction: RedeemInstruction(concise: '', verbose: ''),
                          additionalRequirements: AdditionalRequirements(userIdRequired: false),
                        );
                        products.add(product);
                      }
                    }
                  }
                }
              }
            }
          } else {
            // Old format
            products.add(GiftCardProduct.fromJson(mapItem));
          }
        }
      }
    }

    return GiftCardProductResponse(
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
      data: products,
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
  final String productId;
  final String currency;
  final String walletPin;
  final double amount;
  final double unitPrice;
  final int quantity;
  final bool? addBeneficiary;

  GiftCardPaymentRequest({
    required this.productId,
    required this.currency,
    required this.walletPin,
    required this.amount,
    required this.unitPrice,
    required this.quantity,
    this.addBeneficiary,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestRef': 'GIFT-${DateTime.now().millisecondsSinceEpoch}',
      'billItemId': productId,
      'customerEmail': 'customer@example.com',
      'customerName': 'Customer',
      'customerPhone': '08000000000',
      'requestedAmount': amount,
      'walletPin': walletPin,
      if (addBeneficiary != null) 'addBeneficiary': addBeneficiary,
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
