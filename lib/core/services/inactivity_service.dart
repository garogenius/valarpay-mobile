import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/services/local_storage_service.dart';
import 'package:valarpay/core/services/session_service.dart';

class InactivityService {
  static Timer? _inactivityTimer;
  static DateTime? _lastActivityTime;
  static bool _isActive = false;
  static const String _lastActivityKey = 'last_activity_timestamp';

  /// Start monitoring user inactivity
  static void startMonitoring(BuildContext context) async {
    if (_isActive) return;
    _isActive = true;
    _lastActivityTime = DateTime.now();
    await _saveLastActivityTime();
    _scheduleInactivityCheck(context);
  }

  /// Stop monitoring (when user logs out)
  static void stopMonitoring() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _lastActivityTime = null;
    _isActive = false;
  }

  /// Record user activity
  static void recordActivity() async {
    _lastActivityTime = DateTime.now();
    await _saveLastActivityTime();
  }

  /// Save last activity time to storage
  static Future<void> _saveLastActivityTime() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await LocalStorageService.save(_lastActivityKey, timestamp);
  }

  /// Get last activity time from storage
  static Future<DateTime?> _getLastActivityTime() async {
    final timestamp = await LocalStorageService.get(_lastActivityKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
  }

  /// Get timeout duration based on user settings
  static Future<Duration?> _getTimeoutDuration() async {
    final setting = await LocalStorageService.get('auto_logout_setting');
    
    switch (setting) {
      case 'Password Free Log in':
        return null; // No timeout
      case '60 Minutes Password Free Log in':
        return const Duration(minutes: 60);
      case 'Always Require Password to Log in':
        return null; // Don't auto-logout while using app, only on app resume
      default:
        return const Duration(minutes: 60); // Default
    }
  }

  /// Check if user should be logged out
  static void _scheduleInactivityCheck(BuildContext context) {
    _inactivityTimer?.cancel();
    
    _inactivityTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      final timeout = await _getTimeoutDuration();
      
      // No timeout means password-free login
      if (timeout == null) {
        return;
      }

      final now = DateTime.now();
      final lastActivity = _lastActivityTime ?? now;
      final inactiveDuration = now.difference(lastActivity);

      if (inactiveDuration >= timeout) {
        timer.cancel();
        await _handleAutoLogout(context);
      }
    });
  }

  /// Handle auto-logout
  static Future<void> _handleAutoLogout(BuildContext context) async {
    stopMonitoring();
    
    final setting = await LocalStorageService.get('auto_logout_setting');
    
    // Logout user but keep biometric credentials for quick re-login
    if (setting == 'Always Require Password to Log in') {
      await SessionService(context).logout();
    }
    
    if (context.mounted) {
      // Navigate to biometric login if available, otherwise signin
      final hasBiometric = await LocalStorageService.getBool('pref_biometric_fingerprint') ?? false;
      final hasFaceId = await LocalStorageService.getBool('pref_biometric_faceid') ?? false;
      
      if (hasBiometric || hasFaceId) {
        context.go('/biometric-login');
      } else {
        context.go('/signin');
      }
    }
  }

  /// Check if user should be logged out on app resume
  static Future<bool> shouldLogoutOnResume() async {
    final setting = await LocalStorageService.get('auto_logout_setting');
    
    // Password Free - never logout
    if (setting == 'Password Free Log in' || setting == null) {
      return false;
    }
    
    // Always Require Password - always logout
    if (setting == 'Always Require Password to Log in') {
      return true;
    }
    
    // 60 Minutes - check if timeout exceeded
    final lastActivity = await _getLastActivityTime();
    if (lastActivity == null) {
      return false;
    }
    
    final now = DateTime.now();
    final inactiveDuration = now.difference(lastActivity);
    final shouldLogout = inactiveDuration >= const Duration(minutes: 60);
    
    return shouldLogout;
  }

  /// Check if auto-logout is enabled
  static Future<bool> isEnabled() async {
    final setting = await LocalStorageService.get('auto_logout_setting');
    return setting != 'Password Free Log in';
  }
}
