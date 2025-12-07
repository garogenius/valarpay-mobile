import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/services/local_storage_service.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';

/// Unified Session Timeout Service
///
/// Timeout Rules:
/// - Inactivity (no touching): 2 minutes → logout
/// - App in background: 1 minute → logout
/// - App lifecycle checks on resume
/// - No timeout checks on login pages
/// - Shows feedback when auto-logout occurs
class SessionTimeoutService {
  static Timer? _inactivityTimer;
  static DateTime? _lastActivityTime;
  static DateTime? _backgroundTime;
  static bool _isActive = false;
  static bool _isInBackground = false;
  static const String _lastActivityKey = 'last_activity_timestamp';
  static const String _backgroundTimeKey = 'background_timestamp';

  // Timeout when user is inactive (not touching the app)
  static const Duration _inactivityTimeout = Duration(minutes: 2);

  // Timeout when app is in background
  static const Duration _backgroundTimeout = Duration(minutes: 1);

  // How often to check for timeout
  static const Duration _checkInterval = Duration(seconds: 10);

  // Login/auth routes where timeout should not be checked
  static const List<String> _authRoutes = [
    '/signin',
    '/signup',
    '/passcode-login',
    '/biometric-login',
    '/forgot-password',
    '/reset-password',
    '/verify-otp',
    '/onboarding',
    '/welcome',
  ];

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
    _backgroundTime = null;
    _isActive = false;
    _isInBackground = false;
  }

  /// Record user activity (call this on ANY user interaction)
  /// This resets the inactivity timer
  static void recordActivity() async {
    _lastActivityTime = DateTime.now();
    await _saveLastActivityTime();
  }

  /// Call when app goes to background
  static void onAppPaused() async {
    _isInBackground = true;
    _backgroundTime = DateTime.now();
    await _saveBackgroundTime();
  }

  /// Call when app comes to foreground
  static Future<bool> onAppResumed(BuildContext context) async {
    _isInBackground = false;

    // Don't check timeout if on login/auth pages
    if (_isOnAuthRoute(context)) {
      return false;
    }

    // Check if we should logout due to background timeout
    final shouldLogout = await _checkBackgroundTimeout();

    if (shouldLogout) {
      await _handleAutoLogout(
        context,
        reason: 'Your session expired after 1 minute in the background',
      );
      return true; // Logged out
    }

    // Reset activity time since user is back
    recordActivity();
    return false; // Still logged in
  }

  /// Check if current route is an auth/login route
  static bool _isOnAuthRoute(BuildContext context) {
    try {
      final router = GoRouter.of(context);
      final currentRoute = router.routerDelegate.currentConfiguration.uri.path;

      return _authRoutes.any((route) => currentRoute.contains(route));
    } catch (e) {
      return false;
    }
  }

  /// Save last activity time to storage
  static Future<void> _saveLastActivityTime() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await LocalStorageService.save(_lastActivityKey, timestamp);
  }

  /// Save background time to storage
  static Future<void> _saveBackgroundTime() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await LocalStorageService.save(_backgroundTimeKey, timestamp);
  }

  /// Get last activity time from storage
  static Future<DateTime?> _getLastActivityTime() async {
    final timestamp = await LocalStorageService.get(_lastActivityKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
  }

  /// Get background time from storage
  static Future<DateTime?> _getBackgroundTime() async {
    final timestamp = await LocalStorageService.get(_backgroundTimeKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
  }

  /// Check if background timeout exceeded
  static Future<bool> _checkBackgroundTimeout() async {
    final backgroundTime = _backgroundTime ?? await _getBackgroundTime();
    if (backgroundTime == null) return false;

    final now = DateTime.now();
    final duration = now.difference(backgroundTime);

    return duration >= _backgroundTimeout;
  }

  /// Schedule periodic inactivity checks
  static void _scheduleInactivityCheck(BuildContext context) {
    _inactivityTimer?.cancel();

    // Check every 10 seconds
    _inactivityTimer = Timer.periodic(_checkInterval, (timer) async {
      // Don't check if app is in background
      if (_isInBackground) {
        return;
      }

      // Don't check if on login/auth pages
      if (_isOnAuthRoute(context)) {
        return;
      }

      final now = DateTime.now();
      final lastActivity = _lastActivityTime ?? now;
      final inactiveDuration = now.difference(lastActivity);

      // If user hasn't touched the app for 2 minutes, logout
      if (inactiveDuration >= _inactivityTimeout) {
        timer.cancel();
        await _handleAutoLogout(
          context,
          reason: 'Your session expired after 2 minutes of inactivity',
        );
      }
    });
  }

  /// Handle auto-logout with user feedback
  static Future<void> _handleAutoLogout(
    BuildContext context, {
    String? reason,
  }) async {
    stopMonitoring();

    // Show feedback to user
    if (context.mounted && reason != null) {
      AppMessenger.show(context, message: reason, type: MessageType.warning);
    }

    // Small delay to show the message
    await Future.delayed(const Duration(milliseconds: 500));

    // Clear session
    await SessionService(context).logout();

    if (context.mounted) {
      // Navigate to appropriate login screen
      final hasBiometric =
          await LocalStorageService.getBool('pref_biometric_fingerprint') ??
          false;
      final hasFaceId =
          await LocalStorageService.getBool('pref_biometric_faceid') ?? false;

      if (hasBiometric || hasFaceId) {
        context.go('/biometric-login');
      } else {
        context.go('/passcode-login');
      }
    }
  }

  /// Check if user should be logged out on app resume (from terminated state)
  static Future<bool> shouldLogoutOnResume() async {
    // Check background timeout
    final backgroundTime = await _getBackgroundTime();
    if (backgroundTime != null) {
      final now = DateTime.now();
      final duration = now.difference(backgroundTime);

      if (duration >= _backgroundTimeout) {
        return true;
      }
    }

    // Check inactivity timeout
    final lastActivity = await _getLastActivityTime();
    if (lastActivity != null) {
      final now = DateTime.now();
      final duration = now.difference(lastActivity);

      if (duration >= _inactivityTimeout) {
        return true;
      }
    }

    return false;
  }

  /// Get remaining time before logout (for UI display)
  static Future<Duration?> getRemainingTime() async {
    if (_isInBackground) {
      // Show background timeout remaining
      final backgroundTime = _backgroundTime ?? await _getBackgroundTime();
      if (backgroundTime == null) return _backgroundTimeout;

      final now = DateTime.now();
      final elapsed = now.difference(backgroundTime);
      final remaining = _backgroundTimeout - elapsed;

      return remaining.isNegative ? Duration.zero : remaining;
    } else {
      // Show inactivity timeout remaining
      final lastActivity = _lastActivityTime ?? await _getLastActivityTime();
      if (lastActivity == null) return _inactivityTimeout;

      final now = DateTime.now();
      final elapsed = now.difference(lastActivity);
      final remaining = _inactivityTimeout - elapsed;

      return remaining.isNegative ? Duration.zero : remaining;
    }
  }

  /// Check if monitoring is active
  static bool get isActive => _isActive;

  /// Check if app is in background
  static bool get isInBackground => _isInBackground;

  /// Get current timeout settings (for display)
  static Map<String, Duration> getTimeoutSettings() {
    return {'inactivity': _inactivityTimeout, 'background': _backgroundTimeout};
  }

  /// Add a route to the auth routes list (for custom auth screens)
  static void addAuthRoute(String route) {
    if (!_authRoutes.contains(route)) {
      _authRoutes.add(route);
    }
  }
}
