class VerifyWalletPinResponse {
  final String message;
  final int statusCode;

  VerifyWalletPinResponse({
    required this.message,
    required this.statusCode,
  });

  factory VerifyWalletPinResponse.fromJson(Map<String, dynamic> json) {
    final rawMessage = json['message'];
    String message;
    if (rawMessage is List) {
      message = rawMessage.join(', ');
    } else {
      message = rawMessage?.toString() ?? '';
    }
    return VerifyWalletPinResponse(
      message: message,
      statusCode: json['statusCode'] as int? ?? 200,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
    };
  }

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
