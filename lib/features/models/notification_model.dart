import 'package:intl/intl.dart';

// Notification category enum
enum NotificationCategory {
  TRANSACTIONS,
  SERVICES,
  UPDATES,
  MESSAGES;

  String get value => name;

  static NotificationCategory fromString(String value) {
    return NotificationCategory.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => NotificationCategory.UPDATES,
    );
  }
}

// Notification channel enum
enum NotificationChannel {
  IN_APP,
  EMAIL,
  SMS,
  PUSH;

  String get value => name;

  static NotificationChannel fromString(String value) {
    return NotificationChannel.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => NotificationChannel.IN_APP,
    );
  }
}

// Notification status enum
enum NotificationStatus {
  SENT,
  READ,
  PENDING,
  FAILED,
  DELIVERED;

  String get value => name;

  static NotificationStatus fromString(String value) {
    return NotificationStatus.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => NotificationStatus.SENT,
    );
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String category; // 'TRANSACTIONS', 'SERVICES', 'UPDATES', 'MESSAGES'
  final String channel; // 'IN_APP', 'EMAIL', 'SMS', 'PUSH'
  final String status; // 'SENT', 'READ', 'PENDING', 'FAILED', 'DELIVERED'
  final String title;
  final String message;
  final Map<String, dynamic>? metadata;
  final String? idempotencyKey;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.channel,
    required this.status,
    required this.title,
    required this.message,
    this.metadata,
    this.idempotencyKey,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed property to check if notification is read
  bool get isRead => readAt != null;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      category: json['category'] ?? 'UPDATES',
      channel: json['channel'] ?? 'IN_APP',
      status: json['status'] ?? 'SENT',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
      idempotencyKey: json['idempotencyKey'],
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
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
      'id': id,
      'userId': userId,
      'category': category,
      'channel': channel,
      'status': status,
      'title': title,
      'message': message,
      'metadata': metadata,
      'idempotencyKey': idempotencyKey,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? category,
    String? channel,
    String? status,
    String? title,
    String? message,
    Map<String, dynamic>? metadata,
    String? idempotencyKey,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      channel: channel ?? this.channel,
      status: status ?? this.status,
      title: title ?? this.title,
      message: message ?? this.message,
      metadata: metadata ?? this.metadata,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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

  // Helper method to get icon based on category
  String getIcon() {
    switch (category.toUpperCase()) {
      case 'TRANSACTIONS':
        return 'assets/images/payment_wid/bell.svg';
      case 'SERVICES':
        return 'assets/images/payment_wid/bell.svg';
      case 'UPDATES':
        return 'assets/images/payment_wid/bell.svg';
      case 'MESSAGES':
        return 'assets/images/payment_wid/bell.svg';
      default:
        return 'assets/images/payment_wid/bell.svg';
    }
  }

  // Legacy getter for backward compatibility
  String get type => category.toLowerCase();

  String get formattedTitle {
    if (category == 'TRANSACTIONS') {
      final lowerTitle = title.toLowerCase();
      if (lowerTitle.contains('credit') || lowerTitle.contains('deposit')) {
        return 'Credit Alert';
      } else if (lowerTitle.contains('debit') ||
          lowerTitle.contains('withdrawal') ||
          lowerTitle.contains('transfer') ||
          lowerTitle.contains('sent') ||
          lowerTitle.contains('payment') ||
          lowerTitle.contains('purchase')) {
        return 'Debit Alert';
      }
    }
    return title;
  }

  String get formattedMessage {
    if (category == 'TRANSACTIONS' && metadata != null) {
      final lowerTitle = title.toLowerCase();
      final isCredit =
          lowerTitle.contains('credit') || lowerTitle.contains('deposit');
      final isDebit =
          lowerTitle.contains('debit') ||
          lowerTitle.contains('withdrawal') ||
          lowerTitle.contains('transfer') ||
          lowerTitle.contains('sent') ||
          lowerTitle.contains('payment') ||
          lowerTitle.contains('purchase');

      if (isCredit || isDebit) {
        try {
          final amountVal = metadata?['amount'];
          final amount =
              (amountVal is num)
                  ? amountVal.toDouble()
                  : (double.tryParse(amountVal.toString()) ?? 0.0);

          final balanceVal =
              metadata?['balance'] ??
              metadata?['currentBalance'] ??
              metadata?['bal'];
          final balance =
              (balanceVal is num)
                  ? balanceVal.toDouble()
                  : (balanceVal != null
                      ? double.tryParse(balanceVal.toString())
                      : null);

          final reference =
              metadata?['reference'] ??
              metadata?['transactionRef'] ??
              metadata?['ref'] ??
              '';

          final date = createdAt;
          final formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(date);

          final currency = metadata?['currency'] ?? 'NGN';

          final formatter = NumberFormat('#,##0.00', 'en_US');
          final formattedAmountStr = formatter.format(amount);
          final formattedAmount = '$currency $formattedAmountStr';

          String formattedBalance = '';
          if (balance != null) {
            final formattedBalanceStr = formatter.format(balance);
            formattedBalance = ' Bal: $currency $formattedBalanceStr.';
          }

          if (isCredit) {
            final senderName =
                metadata?['senderName'] ??
                metadata?['source'] ??
                metadata?['sender'] ??
                'Unknown';

            // "Credit: NGN 5,000.00 from John Doe. Ref: 12345678. 17/02/2026 12:30. Bal: NGN 50,000.00."
            if (amount > 0) {
              return 'Credit: $formattedAmount from $senderName. Ref: $reference. $formattedDate.$formattedBalance';
            }
          } else if (isDebit) {
            final recipientName =
                metadata?['beneficiaryName'] ??
                metadata?['recipient'] ??
                metadata?['receiver'] ??
                metadata?['destination'] ??
                metadata?['merchant'] ??
                'Service Provider';

            // "Debit: NGN 5,000.00 to John Doe. Ref: 12345678. 17/02/2026 12:30. Bal: NGN 50,000.00."
            if (amount > 0) {
              return 'Debit: $formattedAmount to $recipientName. Ref: $reference. $formattedDate.$formattedBalance';
            }
          }
        } catch (e) {
          // Fallback to original message if parsing fails
          return message;
        }
      }
    }
    return message;
  }
}

// Pagination metadata model
class NotificationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  NotificationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory NotificationMeta.fromJson(Map<String, dynamic> json) {
    return NotificationMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}

// Response model for notifications API
class NotificationsResponse {
  final String message;
  final int statusCode;
  final List<NotificationModel> notifications;
  final NotificationMeta meta;

  NotificationsResponse({
    required this.message,
    required this.statusCode,
    required this.notifications,
    required this.meta,
  });

  // Computed properties for backward compatibility
  bool get success => statusCode >= 200 && statusCode < 300;
  int get currentPage => meta.page;
  int get totalPages => meta.totalPages;
  int get totalNotifications => meta.total;
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    final metaJson = json['meta'] as Map<String, dynamic>? ?? {};

    return NotificationsResponse(
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 200,
      notifications:
          dataList
              .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
              .toList(),
      meta: NotificationMeta.fromJson(metaJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': notifications.map((n) => n.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}
