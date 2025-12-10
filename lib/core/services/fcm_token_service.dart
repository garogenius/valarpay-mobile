import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:valarpay/features/repositories/notification_repository.dart';
import 'package:valarpay/features/models/device_registration_request.dart';
import 'package:valarpay/core/utils/device_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Simple FCM Token Service - Just gets token and sends to API
class FcmTokenService {
  final NotificationRepository _repository;

  FcmTokenService(this._repository);

  /// Get FCM token and send to API
  Future<void> registerDeviceToken() async {
    log('🔔 registerDeviceToken() started');
    try {
      // Check if Firebase is available
      final messaging = FirebaseMessaging.instance;
      log('🔔 FirebaseMessaging instance obtained');

      // Request permission (required for iOS)
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      log('🔔 Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token with retry logic (APNS token might not be ready immediately)
        String? token;
        int retries = 3;
        int delaySeconds = 2;

        for (int i = 0; i < retries; i++) {
          try {
            token = await messaging.getToken();
            if (token != null) {
              log('✅ FCM Token obtained: ${token.substring(0, 20)}...');
              break;
            }
          } catch (e) {
            if (i < retries - 1) {
              log(
                '⏳ APNS token not ready, waiting ${delaySeconds}s... (attempt ${i + 1}/$retries)',
              );
              await Future.delayed(Duration(seconds: delaySeconds));
              delaySeconds += 2; // Increase delay for next retry
            } else {
              log('⚠️ Failed to get FCM token after $retries attempts: $e');
              rethrow;
            }
          }
        }

        if (token != null) {
          // Send token to API
          await _sendTokenToApi(token);
        } else {
          log('⚠️ FCM Token is null after retries');
        }
      } else {
        log('ℹ️ FCM: User denied notification permission');
      }
    } catch (e) {
      log('ℹ️ FCM Token registration skipped: $e');
      // Don't throw - app should continue without FCM
    }
  }

  /// Send token to API
  Future<void> _sendTokenToApi(String fcmToken) async {
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
      log('✅ Device token registered with API successfully');
    } catch (e) {
      log('⚠️ Failed to register device token with API: $e');
      // Don't throw - this is not critical
    }
  }

  /// Unregister device token (call on logout)
  Future<void> unregisterDeviceToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.deleteToken();
      log('✅ FCM token deleted');
    } catch (e) {
      log('⚠️ Failed to delete FCM token: $e');
    }
  }
}
