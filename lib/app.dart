import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/core/services/user_activity_service.dart';
import 'package:valarpay/core/services/connectivity_service.dart';
import 'package:valarpay/features/providers/idle_provider.dart';
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

    ref.listen<bool>(userIdleProvider, (previous, isIdle) async {
      if (isIdle) {
        ref.read(userProvider.notifier).clearUser();
        SessionService(context).logout2();

        ref.read(userIdleProvider.notifier).stopMonitoring();
      }
    });

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return Listener(
          onPointerDown:
              (_) => ref.read(userIdleProvider.notifier).resetTimer(),
          onPointerMove:
              (_) => ref.read(userIdleProvider.notifier).resetTimer(),
          onPointerUp: (_) => ref.read(userIdleProvider.notifier).resetTimer(),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => ref.read(userIdleProvider.notifier).resetTimer(),

            child: MaterialApp.router(
              title: 'ValarPay - Beyond Banking',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: router,
              builder: (context, child) {
                return GlobalLoadingOverlay(
                  child: Navigator(
                    key: ConnectivityService.navigatorKey,
                    onPopPage: (route, result) => route.didPop(result),
                    pages: [
                      MaterialPage(child: child ?? const SizedBox.shrink()),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
