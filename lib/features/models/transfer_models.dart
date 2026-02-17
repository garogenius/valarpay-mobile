class BanksResponse {
  final List<Bank> data;
  final String message;
  final int statusCode;

  BanksResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory BanksResponse.fromJson(Map<String, dynamic> json) => BanksResponse(
    data:
        (json['data'] as List<dynamic>?)
            ?.map((bank) => Bank.fromJson(bank))
            .toList() ??
        [],
    message: json['message'] ?? 'Success',
    statusCode: json['statusCode'] ?? 200,
  );
}

// Bank Models
class Bank {
  final String name;
  final List<String> alias;
  final String routingKey;
  final String? logoImage;
  final String bankCode;
  final String? nubanCode;

  Bank({
    required this.name,
    required this.alias,
    required this.routingKey,
    this.logoImage,
    required this.bankCode,
    this.nubanCode,
  });

  factory Bank.fromJson(Map<String, dynamic> json) => Bank(
    name: json['name'] ?? '',
    alias: List<String>.from(json['alias'] ?? []),
    routingKey: json['routingKey'] ?? json['code'] ?? '',
    logoImage: json['logoImage'],
    bankCode: json['bankCode'] ?? json['code'] ?? '',
    nubanCode: json['nubanCode'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'alias': alias,
    'routingKey': routingKey,
    if (logoImage != null) 'logoImage': logoImage,
    'bankCode': bankCode,
    if (nubanCode != null) 'nubanCode': nubanCode,
  };

  // Helper getter for display name
  String get displayName => name;
}

class BankMatchResponse {
  final List<Bank> banks;
  final AccountDetails? account;
  final String message;
  final int statusCode;

  BankMatchResponse({
    required this.banks,
    this.account,
    required this.message,
    required this.statusCode,
  });

  factory BankMatchResponse.fromJson(Map<String, dynamic> json) =>
      BankMatchResponse(
        banks:
            (json['data'] as List<dynamic>?)
                ?.map((bank) => Bank.fromJson(bank))
                .toList() ??
            [],
        account:
            json['account'] != null
                ? AccountDetails.fromJson(json['account'])
                : null,
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'] ?? 200,
      );
}

// Transfer Fee Models
class TransferFee {
  final double fee;

  TransferFee({required this.fee});

  factory TransferFee.fromJson(Map<String, dynamic> json) =>
      TransferFee(fee: (json['fee'] ?? 0).toDouble());
}

class TransferFeeResponse {
  final TransferFee data;
  final String message;
  final int statusCode;

  TransferFeeResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory TransferFeeResponse.fromJson(Map<String, dynamic> json) =>
      TransferFeeResponse(
        data: TransferFee.fromJson(json['data'] ?? {}),
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'] ?? 200,
      );
}

// Account Verification Models
class AccountDetails {
  final String responseCode;
  final String responseMessage;
  final String sessionId;
  final String bankCode;
  final String accountNumber;
  final String accountName;
  final String kycLevel;
  final String bvn;

  AccountDetails({
    required this.responseCode,
    required this.responseMessage,
    required this.sessionId,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
    required this.kycLevel,
    required this.bvn,
  });

  factory AccountDetails.fromJson(Map<String, dynamic> json) => AccountDetails(
    responseCode: json['responseCode'] ?? '',
    responseMessage: json['responseMessage'] ?? '',
    sessionId: json['sessionId'] ?? '',
    bankCode: json['bankCode'] ?? '',
    accountNumber: json['accountNumber'] ?? '',
    accountName: json['accountName'] ?? '',
    kycLevel: json['kycLevel'] ?? '',
    bvn: json['bvn'] ?? '',
  );
}

class AccountVerificationResponse {
  final AccountDetails data;
  final String message;
  final int statusCode;

  AccountVerificationResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory AccountVerificationResponse.fromJson(Map<String, dynamic> json) =>
      AccountVerificationResponse(
        data: AccountDetails.fromJson(json['data'] ?? {}),
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'] ?? 200,
      );
}

// Transfer Request Models
class InitiateTransferRequest {
  final String bankCode;
  final String accountNumber;
  final double amount;
  final String currency;
  final String description;
  final String pin;
  final bool saveBeneficiary;
  final String sessionId;

  InitiateTransferRequest({
    required this.bankCode,
    required this.accountNumber,
    required this.amount,
    required this.currency,
    required this.description,
    required this.pin,
    required this.saveBeneficiary,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
    'bankCode': bankCode,
    'accountNumber': accountNumber,
    'amount': amount,
    'currency': currency,
    'description': description,
    'walletPin': pin, // Backend expects 'walletPin', not 'pin'
    "saveBeneficiary": saveBeneficiary,
    "sessionId": sessionId,
  };
}

class VerifyAccountRequest {
  final String accountNumber;
  final String bankCode;

  VerifyAccountRequest({required this.accountNumber, required this.bankCode});

  Map<String, dynamic> toJson() => {
    'accountNumber': accountNumber,
    'bankCode': bankCode,
  };
}

// Transfer Response Models
class TransferResponse {
  final String message;
  final int statusCode;

  TransferResponse({required this.message, required this.statusCode});

  factory TransferResponse.fromJson(Map<String, dynamic> json) =>
      TransferResponse(
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'] ?? 200,
      );
}

// Transaction Models
class DepositDetails {
  final double? amount;
  final double amountPaid;
  final String senderName;
  final String senderBankName;
  final String beneficiaryName;
  final String beneficiaryBankName;
  final String senderAccountNumber;
  final String beneficiaryAccountNumber;

  DepositDetails({
    this.amount,
    required this.amountPaid,
    required this.senderName,
    required this.senderBankName,
    required this.beneficiaryName,
    required this.beneficiaryBankName,
    required this.senderAccountNumber,
    required this.beneficiaryAccountNumber,
  });

  factory DepositDetails.fromJson(Map<String, dynamic> json) => DepositDetails(
    amount: json['amount']?.toDouble(),
    amountPaid: (json['amountPaid'] ?? 0).toDouble(),
    senderName: json['senderName'] ?? '',
    senderBankName: json['senderBankName'] ?? '',
    beneficiaryName: json['beneficiaryName'] ?? '',
    beneficiaryBankName: json['beneficiaryBankName'] ?? '',
    senderAccountNumber: json['senderAccountNumber'] ?? '',
    beneficiaryAccountNumber: json['beneficiaryAccountNumber'] ?? '',
  );
}

class Transaction {
  final String id;
  final String walletId;
  final String? transactionRef;
  final String type;
  final String category;
  final String currency;
  final String status;
  final String description;
  final double previousBalance;
  final double currentBalance;
  final String? reference;
  final dynamic billDetails;
  final dynamic transferDetails;
  final DepositDetails? depositDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.walletId,
    this.transactionRef,
    required this.type,
    required this.category,
    required this.currency,
    required this.status,
    required this.description,
    required this.previousBalance,
    required this.currentBalance,
    this.reference,
    this.billDetails,
    this.transferDetails,
    this.depositDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] ?? '',
    walletId: json['walletId'] ?? '',
    transactionRef: json['transactionRef'],
    type: json['type'] ?? '',
    category: json['category'] ?? '',
    currency: json['currency'] ?? '',
    status: json['status'] ?? '',
    description: json['description'] ?? '',
    previousBalance: (json['previousBalance'] ?? 0).toDouble(),
    currentBalance: (json['currentBalance'] ?? 0).toDouble(),
    reference: json['reference'],
    billDetails: json['billDetails'],
    transferDetails: json['transferDetails'],
    depositDetails:
        json['depositDetails'] != null
            ? DepositDetails.fromJson(json['depositDetails'])
            : null,
    createdAt: DateTime.parse(
      json['createdAt'] ?? DateTime.now().toIso8601String(),
    ),
    updatedAt: DateTime.parse(
      json['updatedAt'] ?? DateTime.now().toIso8601String(),
    ),
  );
}

class TransactionsResponse {
  final List<Transaction> transactions;
  final int totalCount;
  final int totalPages;
  final String message;
  final int statusCode;

  TransactionsResponse({
    required this.transactions,
    required this.totalCount,
    required this.totalPages,
    required this.message,
    required this.statusCode,
  });

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) =>
      TransactionsResponse(
        transactions:
            (json['transactions'] as List<dynamic>?)
                ?.map((transaction) => Transaction.fromJson(transaction))
                .toList() ??
            [],
        totalCount: json['totalCount'] ?? 0,
        totalPages: json['totalPages'] ?? 0,
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'] ?? 200,
      );
}

// QR Code Models
class QRCodeData {
  final String bankCode;
  final String accountNumber;
  final String currency;
  final double fee;
  final String amount;
  final String sessionId;

  QRCodeData({
    required this.bankCode,
    required this.accountNumber,
    required this.currency,
    required this.fee,
    required this.amount,
    required this.sessionId,
  });

  factory QRCodeData.fromJson(Map<String, dynamic> json) => QRCodeData(
    bankCode: json['bankCode'] ?? '',
    accountNumber: json['accountNumber'] ?? '',
    currency: json['currency'] ?? '',
    fee: (json['fee'] ?? 0).toDouble(),
    amount: json['amount'] ?? '',
    sessionId: json['sessionId'] ?? '',
  );
}

class QRCodeResponse {
  final String data;
  final String message;
  final int statusCode;

  QRCodeResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory QRCodeResponse.fromJson(Map<String, dynamic> json) => QRCodeResponse(
    data: json['data'] ?? '',
    message: json['message'] ?? 'Success',
    statusCode: json['statusCode'] ?? 200,
  );
}

class DecodeQRCodeRequest {
  final String qrCode;

  DecodeQRCodeRequest({required this.qrCode});

  Map<String, dynamic> toJson() => {'qrCode': qrCode};
}

class DecodeQRCodeResponse {
  final QRCodeData data;
  final String message;
  final int statusCode;

  DecodeQRCodeResponse({
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory DecodeQRCodeResponse.fromJson(Map<String, dynamic> json) =>
      DecodeQRCodeResponse(
        data: QRCodeData.fromJson(json['data'] ?? {}),
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'] ?? 200,
      );
}
