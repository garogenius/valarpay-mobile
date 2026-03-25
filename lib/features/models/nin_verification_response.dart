class NinVerificationResponse {
  final String? message;
  final String? error;
  final int? statusCode;
  final dynamic user;

  const NinVerificationResponse({
    this.message,
    this.error,
    this.statusCode,
    this.user,
  });

  factory NinVerificationResponse.fromJson(Map<String, dynamic> json) {
    String? parseMessage(dynamic val) {
      if (val is List) return val.join(', ');
      return val?.toString();
    }

    return NinVerificationResponse(
      message: parseMessage(json['message']),
      error: parseMessage(json['error']),
      statusCode: json['statusCode'],
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'error': error,
      'statusCode': statusCode,
      'user': user,
    };
  }

  bool get isSuccess => statusCode == 200 || statusCode == 201;
}
