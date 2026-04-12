
class FlutterwaveBiller {
  final String id;
  final String name;
  final String country;
  final String billerCode;
  final String? billerName;
  final String? billerIcon;
  final String? type;

  FlutterwaveBiller({
    required this.id,
    required this.name,
    required this.country,
    required this.billerCode,
    this.billerName,
    this.billerIcon,
    this.type,
  });

  factory FlutterwaveBiller.fromJson(Map<String, dynamic> json) => FlutterwaveBiller(
        id: json['id']?.toString() ?? json['billerId']?.toString() ?? '',
        name: json['name'] ?? json['planName'] ?? json['billerName'] ?? '',
        country: json['countryISOCode'] ?? json['country'] ?? '',
        billerCode:
            json['billerCode'] ?? json['biller_code'] ?? json['billerId']?.toString() ?? '',
        billerName: json['billerName']?.toString(),
        billerIcon: json['billerIcon']?.toString(),
        type: json['type']?.toString(),
      );
}

class FlutterwaveBillerResponse {
  final List<FlutterwaveBiller> data;
  final String message;
  final int statusCode;

  FlutterwaveBillerResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory FlutterwaveBillerResponse.fromJson(dynamic json) {
    final list = <FlutterwaveBiller>[];
    
    if (json is List) {
      list.addAll(json.map((e) => FlutterwaveBiller.fromJson(e)).toList());
      return FlutterwaveBillerResponse(
        data: list,
        message: 'Success',
        statusCode: 200,
      );
    }

    final dynamic rawData = json['data'] ?? json['billers'] ?? json['content'];

    if (rawData is List) {
      list.addAll(rawData.map((e) => FlutterwaveBiller.fromJson(e)).toList());
    } else if (rawData is Map && rawData['billers'] is List) {
      list.addAll((rawData['billers'] as List).map((e) => FlutterwaveBiller.fromJson(e)).toList());
    }

    return FlutterwaveBillerResponse(
      data: list,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
    );
  }
}

class FlutterwaveProduct {
  final dynamic id;
  final String billerCode;
  final String name;
  final double fee;
  final String itemCode;
  final String labelName;
  final double amount;
  final bool isResolvable;
  final double? payAmount;

  FlutterwaveProduct({
    required this.id,
    required this.billerCode,
    required this.name,
    required this.fee,
    required this.itemCode,
    required this.labelName,
    required this.amount,
    required this.isResolvable,
    this.payAmount,
  });

  factory FlutterwaveProduct.fromJson(Map<String, dynamic> json) => FlutterwaveProduct(
        id: json['id'] ?? json['itemId'] ?? 0,
        billerCode: json['biller_code'] ?? json['billerCode'] ?? '',
        name: json['name'] ?? json['billPaymentProductName'] ?? json['itemName'] ?? '',
        fee: (json['fee'] ?? 0).toDouble(),
        itemCode: json['item_code'] ??
            json['itemCode'] ??
            json['billPaymentProductId']?.toString() ??
            json['itemId']?.toString() ??
            '',
        labelName: json['label_name'] ?? json['labelName'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        isResolvable: json['is_resolvable'] ?? json['isResolvable'] ?? false,
        payAmount: json['payAmount'] != null ? (json['payAmount'] as num).toDouble() : null,
      );
}

class FlutterwaveProductResponse {
  final List<FlutterwaveProduct> data;
  final String message;
  final int statusCode;

  FlutterwaveProductResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory FlutterwaveProductResponse.fromJson(dynamic json) {
    final list = <FlutterwaveProduct>[];

    if (json is List) {
      list.addAll(json.map((e) => FlutterwaveProduct.fromJson(e)).toList());
      return FlutterwaveProductResponse(
        data: list,
        message: 'Success',
        statusCode: 200,
      );
    }

    final dynamic rawData = json['data'] ?? json['items'] ?? json['products'];

    if (rawData is List) {
      list.addAll(rawData.map((e) => FlutterwaveProduct.fromJson(e)).toList());
    } else if (rawData is Map && rawData['products'] is List) {
      list.addAll((rawData['products'] as List).map((e) => FlutterwaveProduct.fromJson(e)).toList());
    }

    return FlutterwaveProductResponse(
      data: list,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
    );
  }
}

class FlutterwaveCustomerValidation {
  final String responseCode;
  final String? address;
  final String responseMessage;
  final String name;
  final String billerCode;
  final String? customer;
  final String? productCode;
  final double fee;
  final double maximum;
  final double minimum;

  FlutterwaveCustomerValidation({
    required this.responseCode,
    this.address,
    required this.responseMessage,
    required this.name,
    required this.billerCode,
    this.customer,
    this.productCode,
    required this.fee,
    required this.maximum,
    required this.minimum,
  });

  factory FlutterwaveCustomerValidation.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return FlutterwaveCustomerValidation(
      responseCode: data['responseCode']?.toString() ?? '00',
      address: data['address']?.toString(),
      responseMessage: data['responseMessage']?.toString() ?? data['message']?.toString() ?? '',
      name: data['name']?.toString() ?? data['customerName']?.toString() ?? '',
      billerCode: data['billerCode']?.toString() ?? '',
      customer: data['customer']?.toString() ?? data['customerId']?.toString(),
      productCode: data['productCode']?.toString() ?? data['billPaymentProductId']?.toString(),
      fee: parseDouble(data['fee']),
      maximum: parseDouble(data['maximum'] ?? data['maximumAmount']),
      minimum: parseDouble(data['minimum'] ?? data['minimumAmount']),
    );
  }
}

class FlutterwavePaymentRequest {
  final String itemCode;
  final String billerCode;
  final String currency;
  final String billerNumber;
  final double amount;
  final String walletPin;
  final String category;

  FlutterwavePaymentRequest({
    required this.itemCode,
    required this.billerCode,
    required this.currency,
    required this.billerNumber,
    required this.amount,
    required this.walletPin,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'itemCode': itemCode,
        'billerCode': billerCode,
        'currency': currency,
        'billerNumber': billerNumber,
        'amount': amount,
        'walletPin': walletPin,
      };
}

class FlutterwavePaymentResponse {
  final String message;
  final int statusCode;
  final String? transactionRef;

  FlutterwavePaymentResponse({
    required this.message,
    required this.statusCode,
    this.transactionRef,
  });

  factory FlutterwavePaymentResponse.fromJson(Map<String, dynamic> json) => FlutterwavePaymentResponse(
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'] ?? 200,
        transactionRef: json['data']?['reference'] ?? json['data']?['transactionRef'],
      );
}

class FlutterwaveCategory {
  final String categoryId;
  final String? categoryName;
  final String? categoryCode;

  FlutterwaveCategory({
    required this.categoryId,
    this.categoryName,
    this.categoryCode,
  });

  factory FlutterwaveCategory.fromJson(Map<String, dynamic> json) => FlutterwaveCategory(
        categoryId: json['categoryId']?.toString() ?? json['id']?.toString() ?? '',
        categoryName: json['categoryName'] ?? json['name'] ?? '',
        categoryCode: json['categoryCode'] ?? json['code'] ?? '',
      );
}

class FlutterwaveCategoryResponse {
  final List<FlutterwaveCategory> data;
  final String message;
  final int statusCode;

  FlutterwaveCategoryResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory FlutterwaveCategoryResponse.fromJson(dynamic json) {
    final list = <FlutterwaveCategory>[];

    if (json is List) {
      list.addAll(json.map((e) => FlutterwaveCategory.fromJson(e)).toList());
      return FlutterwaveCategoryResponse(
        data: list,
        message: 'Success',
        statusCode: 200,
      );
    }

    final dynamic rawData = json['data'] ?? json['categories'] ?? json['content'];

    if (rawData is List) {
      list.addAll(rawData.map((e) => FlutterwaveCategory.fromJson(e)).toList());
    } else if (rawData is Map && rawData['categories'] is List) {
      list.addAll((rawData['categories'] as List).map((e) => FlutterwaveCategory.fromJson(e)).toList());
    }

    return FlutterwaveCategoryResponse(
      data: list,
      message: json['message'] ?? 'Success',
      statusCode: json['statusCode'] ?? 200,
    );
  }
}
