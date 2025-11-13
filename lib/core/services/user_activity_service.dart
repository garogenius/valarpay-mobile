import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/features/models/user.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class UserActivityService {
  static Timer? _timer;
  static const Duration timeoutDuration = Duration(minutes: 20);
  static void startMonitoring(BuildContext context, WidgetRef ref) async {
    UserModel? user = await SessionService.getUser();
    if (user != null) {
      _timer?.cancel();
      _timer = Timer(timeoutDuration, () => _logoutUser(context, ref));
    }
  }

  static void resetTimer(BuildContext context, WidgetRef ref) async {
    UserModel? user = await SessionService.getUser();
    if (user != null) {
      _timer?.cancel();
      _timer = Timer(timeoutDuration, () => _logoutUser(context, ref));
    }
  }

  static void stopMonitoring() {
    _timer?.cancel();
  }

  static Future<void> _logoutUser(BuildContext context, WidgetRef ref) async {
    ref.read(userProvider.notifier).clearUser();
    SessionService(context).logout();
  }
}
