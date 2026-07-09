import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/services/local_storage_service.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/services/connectivity_service.dart';

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
  
  static Timer? _logoutCountdownTimer;
  static bool _isShowingLogoutDialog = false;

  // Timeout when user is inactive (not touching the app)
  static Duration _inactivityTimeout = const Duration(minutes: 60);

  // Timeout when app is in background
  static Duration _backgroundTimeout = const Duration(minutes: 10);

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
    '/create-passcode',
    '/change-passcode',
    '/confirm-passcode',
    // Registration flow routes
    '/sign-up-one',
    '/sign-up-two',
    '/sign-up-three',
    '/verify-email',
    '/verify-phone',
    '/verify-2fa',
    '/create-account',
    '/account-created',
  ];

  /// Load timeout settings from storage
  static Future<void> _loadSettings() async {
    final setting = await LocalStorageService.get('auto_logout_setting');
    
    switch (setting) {
      case 'Password Free Log in':
        // Effectively disable timeout (set to 365 days)
        _inactivityTimeout = const Duration(days: 365);
        _backgroundTimeout = const Duration(days: 365);
        break;
      case '60 Minutes Password Free Log in':
        _inactivityTimeout = const Duration(minutes: 60);
        _backgroundTimeout = const Duration(minutes: 60);
        break;
      case 'Always Require Password to Log in':
        _inactivityTimeout = const Duration(minutes: 5);
        _backgroundTimeout = const Duration(minutes: 1);
        break;
      default:
        // Default to long timeout as per user request (60 mins)
        _inactivityTimeout = const Duration(minutes: 60);
        _backgroundTimeout = const Duration(minutes: 60);
    }
  }

  /// Start monitoring user inactivity
  static void startMonitoring(BuildContext context) async {
    if (_isActive) return;

    await _loadSettings();

    _isActive = true;
    _lastActivityTime = DateTime.now();
    _backgroundTime = null; // Reset background time for new session
    await _saveLastActivityTime();
    _scheduleInactivityCheck(context);
  }

  /// Stop monitoring (when user logs out or on auth screens)
  static void stopMonitoring() async {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _lastActivityTime = null;
    _backgroundTime = null;
    _isActive = false;
    _isInBackground = false;
    _isShowingLogoutDialog = false;
    _logoutCountdownTimer?.cancel();

    // Clear stored timestamps to prevent false timeouts
    await LocalStorageService.remove(_lastActivityKey);
    await LocalStorageService.remove(_backgroundTimeKey);
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

    await _loadSettings();

    // Check if we should logout due to background timeout
    final shouldLogout = await _checkBackgroundTimeout();

    if (shouldLogout) {
      _showLogoutCountdownDialog(context);
      return false; // Will logout after countdown
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
      if (_isInBackground) return;

      // Don't check if on login/auth pages
      if (_isOnAuthRoute(context)) return;

      final now = DateTime.now();
      final lastActivity = _lastActivityTime ?? now;
      final inactiveDuration = now.difference(lastActivity);

      if (inactiveDuration >= _inactivityTimeout) {
        _showLogoutCountdownDialog(context);
      }
    });
  }

  static void _showLogoutCountdownDialog(BuildContext originalContext) {
    if (_isShowingLogoutDialog) return;
    _isShowingLogoutDialog = true;
    int secondsLeft = 10;

    final context = ConnectivityService.navigatorKey.currentContext ?? originalContext;
    if (!context.mounted) {
      _handleAutoLogout(originalContext, reason: 'Your session has expired due to inactivity');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            _logoutCountdownTimer?.cancel();
            _logoutCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (secondsLeft > 1) {
                if (context.mounted) {
                  setState(() {
                    secondsLeft--;
                  });
                }
              } else {
                timer.cancel();
                if (Navigator.canPop(ctx)) {
                  Navigator.pop(ctx);
                }
                _handleAutoLogout(context, reason: 'Your session has expired');
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Session Expiring'),
              content: Text('The app will log you out in $secondsLeft seconds due to inactivity.'),
              actions: [
                TextButton(
                  onPressed: () {
                    _logoutCountdownTimer?.cancel();
                    _isShowingLogoutDialog = false;
                    recordActivity();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Stay Logged In'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      _logoutCountdownTimer?.cancel();
      _isShowingLogoutDialog = false;
      recordActivity();
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
    // If monitoring isn't active, don't check timeouts (user just logged in)
    if (!_isActive) return false;

    await _loadSettings();

    // Grace period: If last activity was very recent (< 10 seconds), skip timeout check
    // This handles the case where user just logged in and app lifecycle triggers
    final lastActivity = _lastActivityTime ?? await _getLastActivityTime();
    if (lastActivity != null) {
      final timeSinceActivity = DateTime.now().difference(lastActivity);
      if (timeSinceActivity.inSeconds < 10) return false;
    }

    // Check background timeout
    final backgroundTime = await _getBackgroundTime();
    if (backgroundTime != null) {
      final now = DateTime.now();
      final duration = now.difference(backgroundTime);

      if (duration >= _backgroundTimeout) return true;
    }

    // Check inactivity timeout
    if (lastActivity != null) {
      final now = DateTime.now();
      final duration = now.difference(lastActivity);

      if (duration >= _inactivityTimeout) return true;
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
