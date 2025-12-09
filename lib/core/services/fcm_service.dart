import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/device_utils.dart';
import 'package:valarpay/features/models/device_registration_request.dart';
import 'package:valarpay/features/repositories/notification_repository.dart';
import 'package:valarpay/features/notifiers/notification_notifier.dart';
import 'package:valarpay/core/services/local_notification_service.dart';

// Global navigator key for navigation from background
import 'package:flutter/material.dart';

class FcmService {
  final NotificationRepository _repository;
  final Ref _ref;
  final GlobalKey<NavigatorState>? navigatorKey;

  FcmService(this._repository, this._ref, {this.navigatorKey});

  /// Initialize FCM and register device
  Future<void> initialize() async {
    try {
      // Initialize local notifications first
      await LocalNotificationService.initialize();

      // Check if Firebase is initialized
      try {
        FirebaseMessaging.instance;
      } catch (e) {
        log(
          'FCM: Firebase not properly configured, skipping FCM initialization',
        );
        return;
      }

      // Request permission for notifications
      final messaging = FirebaseMessaging.instance;

      NotificationSettings? settings;
      try {
        settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
      } catch (e) {
        log('FCM: Permission request failed (dummy Firebase config): $e');
        return;
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('FCM: User granted permission');

        // Get FCM token
        try {
          final token = await messaging.getToken();
          if (token != null) {
            log('FCM Token: $token');
            await _registerDevice(token);
          }
        } catch (e) {
          log('FCM: Failed to get token (dummy Firebase config): $e');
          return;
        }

        // Listen for token refresh
        try {
          messaging.onTokenRefresh.listen((newToken) {
            log('FCM Token refreshed: $newToken');
            _registerDevice(newToken);
          });
        } catch (e) {
          log('FCM: Token refresh listener failed: $e');
        }

        // Setup message handlers
        _setupMessageHandlers();
      } else {
        log('FCM: User declined or has not accepted permission');
      }
    } catch (e) {
      log('FCM initialization error: $e');
      // Don't throw - allow app to continue without FCM
    }
  }

  /// Register device with FCM token
  Future<void> _registerDevice(String fcmToken) async {
    try {
      final deviceId = await DeviceUtils.getDeviceId();
      final deviceName = await DeviceUtils.getDeviceName();
      final osVersion = await DeviceUtils.getDeviceOS();
      final packageInfo = await PackageInfo.fromPlatform();

      // Determine device type
      String deviceType = 'unknown';
      if (osVersion.toLowerCase().contains('ios')) {
        deviceType = 'ios';
      } else if (osVersion.toLowerCase().contains('android')) {
        deviceType = 'android';
      }

      final request = DeviceRegistrationRequest(
        fcmToken: fcmToken,
        deviceId: deviceId,
        deviceName: deviceName,
        deviceType: deviceType,
        osVersion: osVersion,
        appVersion: packageInfo.version,
      );

      await _repository.registerDevice(request);
      log('Device registered successfully with FCM token');
    } catch (e) {
      log('Failed to register device: $e');
    }
  }

  /// Setup message handlers for foreground, background, and terminated states
  void _setupMessageHandlers() {
    final messaging = FirebaseMessaging.instance;

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Foreground message received: ${message.notification?.title}');

      // Refresh notification count when new notification arrives
      _ref.read(notificationNotifierProvider.notifier).fetchUnreadCount();

      // You can show a local notification here if needed
      _handleNotification(message);
    });

    // Handle background messages (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Background message opened: ${message.notification?.title}');
      _handleNotificationTap(message);
    });

    // Check if app was opened from a terminated state via notification
    _checkInitialMessage();
  }

  /// Check if app was opened from a notification (terminated state)
  Future<void> _checkInitialMessage() async {
    final messaging = FirebaseMessaging.instance;
    final initialMessage = await messaging.getInitialMessage();

    if (initialMessage != null) {
      log('App opened from terminated state via notification');
      _handleNotificationTap(initialMessage);
    }
  }

  /// Handle notification received in foreground
  void _handleNotification(RemoteMessage message) {
    // Show local notification in foreground
    LocalNotificationService.showNotification(message);
    log('Notification data: ${message.data}');
  }

  /// Handle notification tap - Navigate to notifications screen with correct tab
  void _handleNotificationTap(RemoteMessage message) {
    log('Notification tapped: ${message.data}');

    // Get notification type/category from message data
    final notificationType =
        message.data['type'] ?? message.data['category'] ?? 'transaction';

    // Map type to tab index
    int tabIndex = 0; // Default to Transactions
    switch (notificationType.toLowerCase()) {
      case 'transaction':
      case 'transactions':
        tabIndex = 0;
        break;
      case 'service':
      case 'services':
        tabIndex = 1;
        break;
      case 'update':
      case 'updates':
        tabIndex = 2;
        break;
      case 'message':
      case 'messages':
        tabIndex = 3;
        break;
    }

    // Navigate to notifications screen with tab index
    if (navigatorKey?.currentContext != null) {
      final context = navigatorKey!.currentContext!;
      context.push('/notifications', extra: {'initialTab': tabIndex});
    }
  }

  /// Unregister device (call on logout)
  Future<void> unregisterDevice() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.deleteToken();
      log('FCM token deleted');
    } catch (e) {
      log('Failed to delete FCM token: $e');
    }
  }
}

/// FCM Service Provider
final fcmServiceProvider = Provider<FcmService>((ref) {
  // You'll need to pass the navigator key from main.dart
  return FcmService(ref.read(notificationRepositoryProvider), ref);
});
