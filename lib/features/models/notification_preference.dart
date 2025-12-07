class NotificationPreference {
  final String id;
  final String userId;
  final String category; // TRANSACTIONS, UPDATES, SERVICES, MESSAGES
  final bool email;
  final bool sms;
  final bool push;
  final bool inApp;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationPreference({
    required this.id,
    required this.userId,
    required this.category,
    required this.email,
    required this.sms,
    required this.push,
    required this.inApp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      category: json['category'] ?? '',
      email: json['email'] ?? false,
      sms: json['sms'] ?? false,
      push: json['push'] ?? false,
      inApp: json['inApp'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'email': email,
      'sms': sms,
      'push': push,
      'inApp': inApp,
    };
  }

  NotificationPreference copyWith({
    String? id,
    String? userId,
    String? category,
    bool? email,
    bool? sms,
    bool? push,
    bool? inApp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationPreference(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      email: email ?? this.email,
      sms: sms ?? this.sms,
      push: push ?? this.push,
      inApp: inApp ?? this.inApp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Response model for preferences API
class NotificationPreferencesResponse {
  final String message;
  final int statusCode;
  final List<NotificationPreference> data;

  NotificationPreferencesResponse({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory NotificationPreferencesResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];

    return NotificationPreferencesResponse(
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 200,
      data:
          dataList
              .map(
                (item) => NotificationPreference.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}
