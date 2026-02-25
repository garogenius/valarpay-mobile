class ApiResponse {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiResponse({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
        message: json['message'] ?? 'Success',
        statusCode: json['statusCode'],
        data: json['data'],
      );
}
