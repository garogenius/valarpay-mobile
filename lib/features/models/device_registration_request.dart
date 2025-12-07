class DeviceRegistrationRequest {
  final String fcmToken;
  final String deviceId;
  final String deviceName;
  final String deviceType; // 'ios' or 'android'
  final String osVersion;
  final String appVersion;

  DeviceRegistrationRequest({
    required this.fcmToken,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.osVersion,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'fcmToken': fcmToken,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'osVersion': osVersion,
      'appVersion': appVersion,
    };
  }
}
