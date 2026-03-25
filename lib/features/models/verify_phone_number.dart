class VerifyPhoneOtpRequest {
  final String? phoneNumber;
  final String? otpCode;
  final String? userId;

  const VerifyPhoneOtpRequest({
    this.phoneNumber,
    this.otpCode,
    this.userId,
  });

  VerifyPhoneOtpRequest copyWith({
    String? phoneNumber,
    String? otpCode,
    String? userId,
  }) {
    return VerifyPhoneOtpRequest(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: otpCode ?? this.otpCode,
      userId: userId ?? this.userId,
    );
  }

  factory VerifyPhoneOtpRequest.fromJson(Map<String, dynamic> json) {
    return VerifyPhoneOtpRequest(
      phoneNumber: json['phoneNumber'],
      otpCode: json['otpCode'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'otpCode': otpCode,
      'userId': userId,
    };
  }
}
