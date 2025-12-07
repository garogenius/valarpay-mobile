class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'transaction', 'service', 'update', 'message'
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'message',
      isRead: json['isRead'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper method to get time ago string
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Helper method to get icon based on type
  String getIcon() {
    switch (type.toLowerCase()) {
      case 'transaction':
        return 'assets/images/payment_wid/bell.svg';
      case 'service':
        return 'assets/images/payment_wid/bell.svg';
      case 'update':
        return 'assets/images/payment_wid/bell.svg';
      case 'message':
        return 'assets/images/payment_wid/bell.svg';
      default:
        return 'assets/images/payment_wid/bell.svg';
    }
  }
}

// Response model for notifications API
class NotificationsResponse {
  final bool success;
  final String message;
  final List<NotificationModel> notifications;
  final int currentPage;
  final int totalPages;
  final int totalNotifications;
  final int unreadCount;

  NotificationsResponse({
    required this.success,
    required this.message,
    required this.notifications,
    required this.currentPage,
    required this.totalPages,
    required this.totalNotifications,
    required this.unreadCount,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final notificationsList = data['notifications'] as List? ?? [];

    return NotificationsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      notifications:
          notificationsList
              .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
              .toList(),
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      totalNotifications: data['totalNotifications'] ?? 0,
      unreadCount: data['unreadCount'] ?? 0,
    );
  }
}
