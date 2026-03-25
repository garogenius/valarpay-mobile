class BvnValidateResponse {
  final String message;
  final int statusCode;

  BvnValidateResponse({
    required this.message,
    required this.statusCode,
  });

  factory BvnValidateResponse.fromJson(Map<String, dynamic> json) {
    final rawMessage = json['message'];
    String message;
    if (rawMessage is List) {
      message = rawMessage.join(', ');
    } else {
      message = rawMessage?.toString() ?? 'BVN verification successful';
    }
    return BvnValidateResponse(
      message: message,
      statusCode: json['statusCode'] ?? 200,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'statusCode': statusCode,
      };
}
