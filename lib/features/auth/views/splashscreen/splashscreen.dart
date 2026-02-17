import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/core/services/local_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
    await Future.delayed(const Duration(milliseconds: 500));
    await _scaleController.forward();
    await _backgroundController.forward();
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
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
      context.go('/');
      return;
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
      // No saved username, go to signin
      context.pushReplacement('/signin');
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
