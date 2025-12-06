import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/services/session_service.dart'
    show SessionService;

final userIdleProvider = StateNotifierProvider<UserIdleNotifier, bool>((ref) {
  return UserIdleNotifier(ref);
});

class UserIdleNotifier extends StateNotifier<bool> {
  UserIdleNotifier(this.ref) : super(false);

  final Ref ref;
  Timer? _timer;

  static const Duration timeoutDuration = Duration(minutes: 20);

  void startMonitoring() async {
    final user = await SessionService.getUser();
    if (user != null) {
      _timer?.cancel();
      _timer = Timer(timeoutDuration, _onTimeout);
    }
  }

  void resetTimer() async {
    final user = await SessionService.getUser();
    if (user != null) {
      state = false;
      _timer?.cancel();
      _timer = Timer(timeoutDuration, _onTimeout);
    }
  }

  void stopMonitoring() {
    _timer?.cancel();
    state = false;
  }

  void _onTimeout() {
    state = true;
  }
}
