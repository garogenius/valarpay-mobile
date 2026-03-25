import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/features/providers/idle_provider.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import '../../widgets/home_widgets/settings_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsListTile(
                      icon: Icons.login_outlined,
                      title: 'Login Settings',
                      onTap: () => context.push('/login-settings'),
                    ),
                    SettingsListTile(
                      icon: Icons.security_outlined,
                      title: 'Security Settings',
                      onTap: () => context.push('/security-settings'),
                    ),
                    SettingsListTile(
                      icon: Icons.pin_outlined,
                      title: 'Transaction PIN Settings',
                      onTap: () => context.push('/transaction-pin-settings'),
                    ),
                    SettingsListTile(
                      icon: Icons.history_outlined,
                      title: 'Login Activity History',
                      onTap: () => context.push('/login-history'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsListTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Finance Settings',
                      onTap: () => context.push('/finance-settings'),
                    ),
                    SettingsListTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notification Settings',
                      onTap: () => context.push('/notification-settings'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SettingsListTile(
                icon: Icons.support_agent_outlined,
                title: 'Close Account',
                onTap: () => context.push('/close-account'),
              ),
              const SizedBox(height: 16),
              SettingsListTile(
                icon: Icons.logout_outlined,
                title: 'Logout',
                onTap: () => _showLogoutDialog(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///  Logout confirmation dialog
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final parentContext = context; // store router context

    showDialog(
      context: context,
      builder:
          (dialogCtx) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogCtx).pop();

                  await ref.read(userProvider.notifier).clearUser();
                  SessionService(context).logout();
                  ref.read(userIdleProvider.notifier).stopMonitoring();

                  AppMessenger.show(
                    parentContext,
                    message: 'You have been logged out successfully',
                    type: MessageType.success,
                  );

                  if (parentContext.mounted) {
                    final username = await SessionService.getUsername();
                    if (username != null) {
                      parentContext.push('/biometric-login');
                    } else {
                      parentContext.go('/signin');
                    }
                  }
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
