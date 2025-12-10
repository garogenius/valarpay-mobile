import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/network/data_state.dart';
import 'package:valarpay/features/models/login.dart';
import 'package:valarpay/features/models/username_request.dart';
import 'package:valarpay/features/models/verify_otp_request.dart';
import 'package:valarpay/features/repositories/auth_repository.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/core/services/fcm_token_service.dart';
import 'package:valarpay/features/notifiers/notification_notifier.dart';

class AuthNotifier extends StateNotifier<DataState<LoginResponse>> {
  final AuthRepository _repository;
  final FcmTokenService? _fcmTokenService;

  AuthNotifier(this._repository, this._fcmTokenService)
    : super(DataState<LoginResponse>.initial());

  /// 🔹 Normal Email/Password Login
  Future<void> login(LoginRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.login(request);
      state = state.copyWith(
        isInitialLoading: false,
        data: [res],
        isDataAvailable: true,
        message: res.message,
      );

      // Register FCM token after successful login (non-blocking)
      _registerFcmToken();
    } catch (e, stack) {
      log('[AuthNotifier Login Error] $e\\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<void> loginWithPasscode(PasscodeLoginRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.loginWithPasscode(request);
      state = state.copyWith(
        isInitialLoading: false,
        data: [res],
        isDataAvailable: true,
        message: res.message,
      );

      // Register FCM token after successful login (non-blocking)
      _registerFcmToken();
    } catch (e, stack) {
      log('[AuthNotifier Passcode Error] $e\\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  /// Register FCM token in background (non-blocking)
  void _registerFcmToken() {
    log('🔔 _registerFcmToken called');
    if (_fcmTokenService != null) {
      log('🔔 FCM Token Service available, registering device...');
      // Run in background, don't await
      _fcmTokenService.registerDeviceToken().catchError((e) {
        log('FCM token registration failed (non-critical): $e');
      });
    } else {
      log('⚠️ FCM Token Service is null - cannot register device');
    }
  }

  Future<void> resend2fa(UsernameRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.resend2fa(request);
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[AuthNotifier 2fa Sending Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<void> verify2fa(VerifyOtpRequest request) async {
    state = state.copyWith(isInitialLoading: true, message: null);
    try {
      final res = await _repository.verify2fa(request);
      state = state.copyWith(
        isInitialLoading: false,
        data: [res],
        isDataAvailable: true,
        message: res.message,
      );
    } catch (e, stack) {
      log('[AuthNotifier 2fa Verification Error] $e\n$stack');
      state = state.copyWith(
        isInitialLoading: false,
        isDataAvailable: false,
        message: e.toString(),
      );
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  void reset() => state = DataState<LoginResponse>.initial();
}

// 🔹 Providers

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.read(apiClientProvider)),
);

final fcmTokenServiceProvider = Provider((ref) {
  return FcmTokenService(ref.read(notificationRepositoryProvider));
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, DataState<LoginResponse>>(
      (ref) => AuthNotifier(
        ref.read(authRepositoryProvider),
        ref.read(fcmTokenServiceProvider),
      ),
    );
