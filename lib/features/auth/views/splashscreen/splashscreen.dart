import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/core/services/local_storage_service.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/notifiers/notification_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _backgroundController;
  late AnimationController _textController;

  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _borderRadiusAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 60.0, end: 120.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _borderRadiusAnimation = Tween<double>(begin: 12.0, end: 60.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _backgroundAnimation = ColorTween(
      begin: const Color(0xFF000000),
      end: const Color(0xFFF76301),
    ).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // Start animation and check session
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 50));
    await _scaleController.forward();
    await _backgroundController.forward();
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _checkSession();
  }

  Future<void> _checkSession() async {
    final savedUsername = await SessionService.getUsername();
    final autoLogoutSetting = await LocalStorageService.get(
      'auto_logout_setting',
    );
    final isLoggedIn = await SessionService.isLoggedIn();

    if (!mounted) return;

    // Check if Password Free Login is enabled and user is already logged in
    if (autoLogoutSetting == 'Password Free Log in' && isLoggedIn) {
      // In background preload data
      _preloadEssentialData();
      context.go('/');
      return;
    }

    // Check for pending signup draft
    final signUpDraft = await SessionService.getSignUpDraft();
    if (signUpDraft != null) {
      if (!mounted) return;
      
      // Determine where the user left off
      if (signUpDraft.email != null && signUpDraft.password != null) {
        context.go('/verify-email', extra: signUpDraft);
        return;
      }
    }

    // On app restart, always require login
    // If user has saved credentials, go to biometric/passcode login
    // Otherwise, go to signin
    
    if (savedUsername != null) {
      // Has saved username, go to biometric/passcode login
      final fpEnabled = await LocalStorageService.getBool(
        'pref_biometric_fingerprint',
      );
      final faceEnabled = await LocalStorageService.getBool(
        'pref_biometric_faceid',
      );
      final hasPasscode = await LocalStorageService.getBool('has_passcode');

      // If any lock method is enabled, show lock screen
      if ((fpEnabled ?? false) ||
          (faceEnabled ?? false) ||
          (hasPasscode ?? false)) {
        context.pushReplacement('/biometric-login');
      } else {
        // No lock enabled, go to passcode login
        context.pushReplacement('/passcode-login');
      }
    } else {
      // No saved username, check onboarding seen
      final hasSeenOnboarding = await LocalStorageService.getBool(
        'has_seen_onboarding',
      );
      if (hasSeenOnboarding ?? false) {
        context.pushReplacement('/signin');
      } else {
        context.pushReplacement('/intro');
      }
    }
  }

  Future<void> _preloadEssentialData() async {
    try {
      final user = await SessionService.getUser();
      if (user != null) {
        ref.read(userProvider.notifier).setUser(user);
        // Refresh token / profile
        ref.read(userNotifierProvider.notifier).refreshUserProfile();
        ref.read(notificationNotifierProvider.notifier).fetchUnreadCount();
      }
    } catch (e) {
      // Silently fail
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _backgroundController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleController,
          _backgroundController,
          _textController,
        ]),
        builder: (context, child) {
          return Scaffold(
            backgroundColor: _backgroundAnimation.value,
            body: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo animation
                  Container(
                    width: _scaleAnimation.value,
                    height: _scaleAnimation.value,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        _borderRadiusAnimation.value,
                      ),
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          _borderRadiusAnimation.value,
                        ),
                        child: Image.asset(
                          'assets/gifs/valarpay.gif',
                          width: _scaleAnimation.value * 0.8,
                          height: _scaleAnimation.value * 0.8,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // App name fade-in
                  // Opacity(
                  //   opacity: _textOpacityAnimation.value,
                  //   child: const Padding(
                  //     padding: EdgeInsets.only(left: 16),
                  //     child: Text(
                  //       'ValarPay',
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 32,
                  //         fontWeight: FontWeight.w600,
                  //         fontFamily: 'SF Pro',
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );

    // return AnnotatedRegion<SystemUiOverlayStyle>(
    // value: const SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   statusBarIconBrightness: Brightness.light,
    // ),
    // child: AnimatedBuilder(
    //   animation: Listenable.merge([
    //     _scaleController,
    //     _backgroundController,
    //     _textController,
    //   ]),
    //   builder: (context, child) {
    //     return Scaffold(
    //       backgroundColor: _backgroundAnimation.value,
    //       body: Center(
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             // Logo animation
    //             Container(
    //               width: _scaleAnimation.value,
    //               height: _scaleAnimation.value,
    //               decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(
    //                   _borderRadiusAnimation.value,
    //                 ),
    //               ),
    //               child: Center(
    //                 child: ClipRRect(
    //                   borderRadius: BorderRadius.circular(
    //                     _borderRadiusAnimation.value,
    //                   ),
    //                   child: Image.asset(
    //                     'assets/images/launcher.png',
    //                     width: _scaleAnimation.value * 0.8,
    //                     height: _scaleAnimation.value * 0.8,
    //                     fit: BoxFit.cover,
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             // App name fade-in
    //             Opacity(
    //               opacity: _textOpacityAnimation.value,
    //               child: const Padding(
    //                 padding: EdgeInsets.only(left: 16),
    //                 child: Text(
    //                   'ValarPay',
    //                   style: TextStyle(
    //                     color: Colors.white,
    //                     fontSize: 32,
    //                     fontWeight: FontWeight.w600,
    //                     fontFamily: 'SF Pro',
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // ),
    // );
  }
}
