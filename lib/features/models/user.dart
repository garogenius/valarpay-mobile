import 'package:valarpay/features/models/wallet.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String fullname;
  final String role;
  final String status;
  final String? phoneNumber;
  final String? gender;
  final String? country;
  final String? businessName;
  final String? companyRegistrationNumber;
  final String? nin;
  final String? address;
  final String? state;
  final String? city;
  final String? selfieBase64Image;
  final String? accountType;
  final String? profileImageFilename;
  final String? profileImageUrl;
  final String? referralCode;
  final String? dateOfBirth;
  final String? currency;
  final String? tierLevel;
  final String? employmentStatus;
  final String? occupation;
  final String? passportNumber;
  final String? passportCountry;
  final String? passportIssueDate;
  final String? passportExpiryDate;
  final String? passportDocumentUrl;
  final String? bankStatementUrl;
  final String? bankStatementIssueDate;
  final String? bankStatementExpiryDate;
  final String? utilityBillUrl;
  final String? utilityBillIssueDate;
  final String? utilityBillExpiryDate;
  final String? primaryPurpose;
  final String? sourceOfFunds;
  final String? postalCode;
  final num? expectedMonthlyInflow;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isBvnVerified;
  final bool isNinVerified;
  final bool isAddressVerified;
  final bool isWalletPinSet;
  final bool isBusiness;
  final bool isBusinessRegistered;
  final bool enabledTwoFa;
  final bool isPasscodeSet;
  final int tokenVersion;
  final num dailyCummulativeTransactionLimit;
  final num cummulativeBalanceLimit;
  final List<WalletModel> wallets;
  
  String get fullName => fullname;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.fullname,
    required this.role,
    required this.status,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    this.phoneNumber,
    this.gender,
    this.country,
    this.businessName,
    this.companyRegistrationNumber,
    this.nin,
    this.address,
    this.state,
    this.city,
    this.selfieBase64Image,
    this.accountType,
    this.profileImageFilename,
    this.profileImageUrl,
    this.referralCode,
    this.dateOfBirth,
    this.currency,
    this.tierLevel,
    this.employmentStatus,
    this.occupation,
    this.passportNumber,
    this.passportCountry,
    this.passportIssueDate,
    this.passportExpiryDate,
    this.passportDocumentUrl,
    this.bankStatementUrl,
    this.bankStatementIssueDate,
    this.bankStatementExpiryDate,
    this.utilityBillUrl,
    this.utilityBillIssueDate,
    this.utilityBillExpiryDate,
    this.primaryPurpose,
    this.sourceOfFunds,
    this.postalCode,
    this.expectedMonthlyInflow,
    this.createdAt,
    this.updatedAt,
    this.isBvnVerified = false,
    this.isNinVerified = false,
    this.isAddressVerified = false,
    this.isWalletPinSet = false,
    this.isBusiness = false,
    this.isBusinessRegistered = false,
    this.enabledTwoFa = false,
    this.isPasscodeSet = false,
    this.tokenVersion = 0,
    this.dailyCummulativeTransactionLimit = 0,
    this.cummulativeBalanceLimit = 0,
    this.wallets = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final walletList =
        (json['wallet'] as List?)
            ?.map((wallet) => WalletModel.fromJson(wallet))
            .toList() ??
        [];

    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullname: json['fullname'],
      role: json['role'] ?? 'USER',
      status: json['status'] ?? 'ACTIVE',
      isEmailVerified: json['isEmailVerified'] ?? json['is_email_verified'] ?? json['emailVerified'] ?? json['email_verified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? json['is_phone_verified'] ?? json['phoneVerified'] ?? json['phone_verified'] ?? false,
      phoneNumber: json['phoneNumber'] ?? json['phone_number'] ?? json['phone'],
      gender: json['gender'],
      country: json['country'],
      businessName: json['businessName'],
      companyRegistrationNumber: json['companyRegistrationNumber'],
      nin: json['nin'],
      address: json['address'],
      state: json['state'],
      city: json['city'],
      selfieBase64Image: json['selfieBase64Image'],
      accountType: json['accountType'],
      profileImageFilename: json['profileImageFilename'],
      profileImageUrl: json['profileImageUrl'],
      referralCode: json['referralCode'],
      dateOfBirth: json['dateOfBirth'],
      currency: json['currency'],
      tierLevel: json['tierLevel'],
      employmentStatus: json['employmentStatus'] ?? json['employment_status'],
      occupation: json['occupation'],
      passportNumber: json['passportNumber'] ?? json['passport_number'],
      passportCountry: json['passportCountry'] ?? json['passport_country'],
      passportIssueDate: json['passportIssueDate'] ?? json['passport_issue_date'],
      passportExpiryDate: json['passportExpiryDate'] ?? json['passport_expiry_date'],
      passportDocumentUrl: json['passportDocumentUrl'] ?? json['passport_document_url'],
      bankStatementUrl: json['bankStatementUrl'] ?? json['bank_statement_url'],
      bankStatementIssueDate: json['bankStatementIssueDate'] ?? json['bank_statement_issue_date'],
      bankStatementExpiryDate: json['bankStatementExpiryDate'] ?? json['bank_statement_expiry_date'],
      utilityBillUrl: json['utilityBillUrl'] ?? json['utility_bill_url'],
      utilityBillIssueDate: json['utilityBillIssueDate'] ?? json['utility_bill_issue_date'],
      utilityBillExpiryDate: json['utilityBillExpiryDate'] ?? json['utility_bill_expiry_date'],
      primaryPurpose: json['primaryPurpose'] ?? json['primary_purpose'],
      sourceOfFunds: json['sourceOfFunds'] ?? json['source_of_funds'],
      postalCode: json['postalCode'] ?? json['postal_code'],
      expectedMonthlyInflow: json['expectedMonthlyInflow'] ?? json['expected_monthly_inflow'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      isBvnVerified: json['isBvnVerified'] ?? false,
      isNinVerified: json['isNinVerified'] ?? false,
      isAddressVerified: json['isAddressVerified'] ?? false,
      isWalletPinSet: json['isWalletPinSet'] ?? json['is_wallet_pin_set'] ?? json['pin_set'] ?? false,
      isBusiness: json['isBusiness'] ?? false,
      isBusinessRegistered: json['isBusinessRegistered'] ?? false,
      enabledTwoFa: json['enabledTwoFa'] ?? false,
      isPasscodeSet: json['isPasscodeSet'] ?? json['is_passcode_set'] ?? false,
      tokenVersion: json['tokenVersion'] ?? 0,
      dailyCummulativeTransactionLimit:
          json['dailyCummulativeTransactionLimit'] ?? 0,
      cummulativeBalanceLimit: json['cummulativeBalanceLimit'] ?? 0,
      wallets: walletList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'fullname': fullname,
    'role': role,
    'status': status,
    'isEmailVerified': isEmailVerified,
    'isPhoneVerified': isPhoneVerified,
    'phoneNumber': phoneNumber,
    'gender': gender,
    'country': country,
    'businessName': businessName,
    'companyRegistrationNumber': companyRegistrationNumber,
    'nin': nin,
    'address': address,
    'state': state,
    'city': city,
    'selfieBase64Image': selfieBase64Image,
    'accountType': accountType,
    'profileImageFilename': profileImageFilename,
    'profileImageUrl': profileImageUrl,
    'referralCode': referralCode,
    'dateOfBirth': dateOfBirth,
    'currency': currency,
    'tierLevel': tierLevel,
    'employmentStatus': employmentStatus,
    'occupation': occupation,
    'passportNumber': passportNumber,
    'passportCountry': passportCountry,
    'passportIssueDate': passportIssueDate,
    'passportExpiryDate': passportExpiryDate,
    'passportDocumentUrl': passportDocumentUrl,
    'bankStatementUrl': bankStatementUrl,
    'bankStatementIssueDate': bankStatementIssueDate,
    'bankStatementExpiryDate': bankStatementExpiryDate,
    'utilityBillUrl': utilityBillUrl,
    'utilityBillIssueDate': utilityBillIssueDate,
    'utilityBillExpiryDate': utilityBillExpiryDate,
    'primaryPurpose': primaryPurpose,
    'sourceOfFunds': sourceOfFunds,
    'postalCode': postalCode,
    'expectedMonthlyInflow': expectedMonthlyInflow,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'isBvnVerified': isBvnVerified,
    'isNinVerified': isNinVerified,
    'isAddressVerified': isAddressVerified,
    'isWalletPinSet': isWalletPinSet,
    'isBusiness': isBusiness,
    'isBusinessRegistered': isBusinessRegistered,
    'enabledTwoFa': enabledTwoFa,
    'isPasscodeSet': isPasscodeSet,
    'tokenVersion': tokenVersion,
    'dailyCummulativeTransactionLimit': dailyCummulativeTransactionLimit,
    'cummulativeBalanceLimit': cummulativeBalanceLimit,
    'wallet': wallets.map((w) => w.toJson()).toList(),
  };
}
