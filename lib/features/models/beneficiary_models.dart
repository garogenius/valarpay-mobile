class Beneficiary {
  final String id;
  final String userId;
  final String type;
  final String bankName;
  final String bankCode;
  final String accountNumber;
  final String accountName;
  final String? network;
  final String? favouriteName;
  final String? billType;
  final String? billerNumber;
  final String? operatorId;
  final String? billerCode;
  final String? itemCode;
  final String currency;
  final String createdAt;
  final String updatedAt;

  Beneficiary({
    required this.id,
    required this.userId,
    required this.type,
    required this.bankName,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
    this.network,
    this.favouriteName,
    this.billType,
    this.billerNumber,
    this.operatorId,
    this.billerCode,
    this.itemCode,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      bankCode: json['bankCode']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      accountName: json['accountName']?.toString() ?? '',
      network: json['network']?.toString(),
      favouriteName: json['favouriteName']?.toString(),
      billType: json['billType']?.toString(),
      billerNumber: json['billerNumber']?.toString(),
      operatorId: json['operatorId']?.toString(),
      billerCode: json['billerCode']?.toString(),
      itemCode: json['itemCode']?.toString(),
      currency: json['currency']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'bankName': bankName,
      'bankCode': bankCode,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'network': network,
      'favouriteName': favouriteName,
      'billType': billType,
      'billerNumber': billerNumber,
      'operatorId': operatorId,
      'billerCode': billerCode,
      'itemCode': itemCode,
      'currency': currency,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class BeneficiariesResponse {
  final String message;
  final int statusCode;
  final List<Beneficiary> data;

  BeneficiariesResponse({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory BeneficiariesResponse.fromJson(Map<String, dynamic> json) {
    return BeneficiariesResponse(
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => Beneficiary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
