import 'package:valarpay/features/models/user.dart';

class LoginRequest {
  final String username;
  final String password;
  final String ipAddress;
  final String deviceName;
  final String operatingSystem;

  LoginRequest({
    required this.username,
    required this.password,
    required this.ipAddress,
    required this.deviceName,
    required this.operatingSystem,
  });

  Map<String, dynamic> toJson() => {
    "username": username,
    "password": password,
    "ipAddress": ipAddress,
    "deviceName": deviceName,
    "operatingSystem": operatingSystem,
  };
}

class PasscodeLoginRequest {
  final String username;
  final String passcode;
  final String ipAddress;
  final String deviceName;
  final String operatingSystem;

  PasscodeLoginRequest({
    required this.username,
    required this.passcode,
    required this.ipAddress,
    required this.deviceName,
    required this.operatingSystem,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'passcode': passcode,
      'ipAddress': ipAddress,
      'deviceName': deviceName,
      'operatingSystem': operatingSystem,
    };
  }
}

class LoginResponse {
  final String message;
  final UserModel user;
  final String? accessToken;
  final int statusCode;

  LoginResponse({
    required this.message,
    required this.user,
    this.accessToken,
    required this.statusCode,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] : json;
    final userJson = json['user'] ?? data['user'] ?? data;
    final token = json['accessToken'] ?? json['token'] ?? data['accessToken'] ?? data['token'];

    final rawMessage = json['message'];
    String message;
    if (rawMessage is List) {
      message = rawMessage.join(', ');
    } else {
      message = rawMessage?.toString() ?? '';
    }

    return LoginResponse(
      message: message,
      user: UserModel.fromJson(userJson),
      accessToken: token?.toString(),
      statusCode: json['statusCode'] ?? 200,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'user': user.toJson(),
    'accessToken': accessToken,
    'statusCode': statusCode,
  };
}
