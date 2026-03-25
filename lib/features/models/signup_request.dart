class SignUpRequest {
  final String? username;
  final String? fullname;
  final String? email;
  final String? phoneNumber;
  final String? password;
  final String? dateOfBirth;
  final String? countryCode;
  final String? referralCode;
  final String? accountType;
  final String? businessName;
  final String? companyRegistrationNumber;
  final String? nin;
  final String? bvn;
  final String? selfieImage;
  final List<String>? livenessImages;

  const SignUpRequest({
    this.username,
    this.fullname,
    this.email,
    this.phoneNumber,
    this.password,
    this.dateOfBirth,
    this.countryCode,
    this.referralCode,
    this.accountType,
    this.businessName,
    this.companyRegistrationNumber,
    this.nin,
    this.bvn,
    this.selfieImage,
    this.livenessImages,
  });

  SignUpRequest copyWith({
    String? username,
    String? fullname,
    String? email,
    String? phoneNumber,
    String? password,
    String? dateOfBirth,
    String? countryCode,
    String? referralCode,
    String? accountType,
    String? businessName,
    String? companyRegistrationNumber,
    String? nin,
    String? bvn,
    String? selfieImage,
    List<String>? livenessImages,
  }) {
    return SignUpRequest(
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      countryCode: countryCode ?? this.countryCode,
      referralCode: referralCode ?? this.referralCode,
      accountType: accountType ?? this.accountType,
      businessName: businessName ?? this.businessName,
      companyRegistrationNumber:
          companyRegistrationNumber ?? this.companyRegistrationNumber,
      nin: nin ?? this.nin,
      bvn: bvn ?? this.bvn,
      selfieImage: selfieImage ?? this.selfieImage,
      livenessImages: livenessImages ?? this.livenessImages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (username != null) 'username': username,
      if (fullname != null) 'fullname': fullname,
      if (email != null) 'email': email,
      if (phoneNumber != null && phoneNumber!.isNotEmpty) 'phoneNumber': phoneNumber,
      if (password != null) 'password': password,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (countryCode != null) 'currency': countryCode,
      if (referralCode != null && referralCode!.isNotEmpty) 'referralCode': referralCode,
      if (accountType != null) 'accountType': accountType,
      if (businessName != null) 'businessName': businessName,
      if (companyRegistrationNumber != null) 'companyRegistrationNumber': companyRegistrationNumber,
      if (nin != null) 'nin': nin,
      if (bvn != null) 'bvn': bvn,
      if (selfieImage != null) 'selfieImage': selfieImage,
      if (livenessImages != null) 'livenessImages': livenessImages,
    };
  }

  static SignUpRequest fromJson(Map<String, dynamic> json) {
    return SignUpRequest(
      username: json['username'],
      fullname: json['fullname'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      password: json['password'],
      dateOfBirth: json['dateOfBirth'],
      countryCode: json['countryCode'],
      referralCode: json['referralCode'],
      accountType: json['accountType'],
      businessName: json['businessName'],
      companyRegistrationNumber: json['companyRegistrationNumber'],
      nin: json['nin'],
      bvn: json['bvn'],
      selfieImage: json['selfieImage'],
      livenessImages: (json['livenessImages'] as List?)?.cast<String>(),
    );
  }
}
