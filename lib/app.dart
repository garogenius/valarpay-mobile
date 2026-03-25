import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/core/services/user_activity_service.dart';
import 'package:valarpay/core/services/connectivity_service.dart';
import 'package:valarpay/core/services/session_timeout_service.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import '../core/routing/app_router.dart';
import '../core/themes/app_theme.dart';
import '../core/providers/theme_provider.dart';
import '../core/widgets/global_loading_overlay.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _connectivityService.initialize();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return Listener(
          onPointerDown: (_) => SessionTimeoutService.recordActivity(),
          onPointerMove: (_) => SessionTimeoutService.recordActivity(),
          onPointerUp: (_) => SessionTimeoutService.recordActivity(),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => SessionTimeoutService.recordActivity(),

            child: MaterialApp.router(
              title: 'ValarPay',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: router,
              builder: (context, child) {
                return GlobalLoadingOverlay(
                  child: child ?? const SizedBox.shrink(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
