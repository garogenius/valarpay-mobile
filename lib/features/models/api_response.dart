class ApiResponse {
  final String message;
  final int? statusCode;
  final bool? isSuccess;
  final dynamic data;

  ApiResponse({
    required this.message,
    this.statusCode,
    this.isSuccess,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    final rawMessage = json['message'];
    String message;
    if (rawMessage is List) {
      message = rawMessage.join(', ');
    } else {
      message = rawMessage?.toString() ?? 'Success';
    }
    
    // Attempt to parse 'status' or 'success' fields. Sometimes they are booleans, sometimes strings
    bool? parsedSuccess;
    if (json.containsKey('status')) {
      parsedSuccess = json['status'] is bool ? json['status'] : json['status']?.toString().toLowerCase() == 'true';
    } else if (json.containsKey('success')) {
      parsedSuccess = json['success'] is bool ? json['success'] : json['success']?.toString().toLowerCase() == 'true';
    }

    return ApiResponse(
      message: message,
      statusCode: json['statusCode'],
      isSuccess: parsedSuccess,
      data: json['data'],
    );
  }

  static String getErrorMessage(dynamic data) {
    if (data == null) return 'An error occurred';
    
    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message is List) {
        return message.join(', ');
      }
      return message?.toString() ?? 'An error occurred';
    }
    
    if (data is List) {
      if (data.isNotEmpty && data[0] is Map) {
        return getErrorMessage(data[0]);
      }
      return data.toString();
    }
    if (data is String) {
      final lowerData = data.toLowerCase();
      if (lowerData.contains('<html') || lowerData.contains('<body>') || lowerData.contains('gateway time-out') || lowerData.contains('bad gateway')) {
        return 'Server is currently unavailable. Please try again later.';
      }
      return data;
    }
    
    return data.toString();
  }
}
