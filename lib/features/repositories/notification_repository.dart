import 'package:dio/dio.dart';
import 'package:valarpay/core/constants/api_endpoints.dart';
import 'package:valarpay/core/network/api_client.dart';
import 'package:valarpay/features/models/notification_model.dart';
import 'package:valarpay/features/models/device_registration_request.dart';

class NotificationRepository {
  final ApiClient apiClient;

  NotificationRepository(this.apiClient);

  /// Register device for push notifications
  Future<Map<String, dynamic>> registerDevice(
    DeviceRegistrationRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.registerDevice,
        data: request.toJson(),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to register device',
      );
    }
  }

  /// Get notification count (unread count)
  Future<int> getNotificationCount() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getNotificationCount);
      // Assuming API returns { "success": true, "data": { "unreadCount": 5 } }
      final data = response.data['data'] ?? {};
      return data['count'] ?? 0;
    } catch (_) {
      // Return 0 on error instead of throwing
      return 0;
    }
  }

  /// Get all notifications with optional filters
  Future<NotificationsResponse> getNotifications({
    int? page,
    int? limit,
    String? category,
    String? status,
    bool? isRead,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (isRead != null) queryParams['isRead'] = isRead.toString();

      final response = await apiClient.get(
        ApiEndpoints.getNotifications,
        query: queryParams.isNotEmpty ? queryParams : null,
      );

      return NotificationsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch notifications',
      );
    }
  }

  /// Mark notification as read
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      final response = await apiClient.put(
        '${ApiEndpoints.markNotificationAsRead}/$notificationId/read',
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to mark notification as read',
      );
    }
  }

  /// Mark all notifications as read
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await apiClient.put(
        '${ApiEndpoints.markNotificationAsRead}/read-all',
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to mark all notifications as read',
      );
    }
  }



  /// Get notification preferences
  Future<List<dynamic>> getNotificationPreferences() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.notificationPreferences,
      );

      // Return the data array from response
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to fetch notification preferences',
      );
    }
  }

  /// Update notification preference for a category
  Future<Map<String, dynamic>> updateNotificationPreference({
    required String category,
    required bool email,
    required bool sms,
    required bool push,
    required bool inApp,
  }) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.notificationPreferences,
        data: {
          'category': category,
          'email': email,
          'sms': sms,
          'push': push,
          'inApp': inApp,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to update notification preferences',
      );
    }
  }
}
