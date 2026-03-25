class LoginActivity {
  final String id;
  final DateTime timestamp;
  final String deviceName;
  final String deviceId;
  final String status; // 'success', 'failed'
  final String? ipAddress;
  final String? location;
  final bool isCurrentDevice;

  LoginActivity({
    required this.id,
    required this.timestamp,
    required this.deviceName,
    required this.deviceId,
    required this.status,
    this.ipAddress,
    this.location,
    this.isCurrentDevice = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'deviceName': deviceName,
      'deviceId': deviceId,
      'status': status,
      'ipAddress': ipAddress,
      'location': location,
      'isCurrentDevice': isCurrentDevice,
    };
  }

  factory LoginActivity.fromJson(Map<String, dynamic> json) {
    return LoginActivity(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      deviceName: json['deviceName'],
      deviceId: json['deviceId'],
      status: json['status'],
      ipAddress: json['ipAddress'],
      location: json['location'],
      isCurrentDevice: json['isCurrentDevice'] ?? false,
    );
  }
}
