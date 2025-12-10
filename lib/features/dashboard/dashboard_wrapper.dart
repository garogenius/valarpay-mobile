import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/features/dashboard/view/KYC/BVN.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/core/services/session_timeout_service.dart';
import 'package:valarpay/core/services/local_storage_service.dart';
import 'package:valarpay/core/services/biometric_transaction_tracker.dart';
import '/features/dashboard/widgets/navbar.dart';

class DashboardWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const DashboardWrapper({super.key, required this.child});

  @override
  ConsumerState<DashboardWrapper> createState() => _DashboardWrapperState();
}

class _DashboardWrapperState extends ConsumerState<DashboardWrapper>
    with WidgetsBindingObserver {
  bool _hasShownPasscodePrompt = false;
  DateTime? _lastPausedTime;
  static const _biometricGracePeriod = Duration(seconds: 5);
  static bool _isBiometricInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowModals();
      SessionTimeoutService.startMonitoring(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive) {
      // App is inactive (biometric prompt, system dialog, etc.)
      // Don't do anything, just log it
      return;
    } else if (state == AppLifecycleState.paused) {
      // Save activity time when app goes to background
      _lastPausedTime = DateTime.now();
      SessionTimeoutService.onAppPaused();
      SessionTimeoutService.recordActivity();
    } else if (state == AppLifecycleState.resumed) {
      // PRIORITY 1: Check if transaction biometric is in progress
      if (BiometricTransactionTracker.isInProgress()) {
        SessionTimeoutService.recordActivity();
        return;
      }

      // PRIORITY 2: Check if biometric authentication flag is set
      if (_isBiometricInProgress) {
        SessionTimeoutService.recordActivity();
        _isBiometricInProgress = false; // Reset flag
        return;
      }

      // PRIORITY 3: Check if this is a quick resume (likely biometric authentication)
      final now = DateTime.now();
      final pauseDuration =
          _lastPausedTime != null ? now.difference(_lastPausedTime!) : null;

      final isQuickResume =
          pauseDuration != null && pauseDuration < _biometricGracePeriod;

      if (isQuickResume) {
        // This is likely biometric authentication, don't logout
        SessionTimeoutService.recordActivity();
        return;
      }

      // Check if user should be logged out based on settings
      final shouldLogout = await SessionTimeoutService.shouldLogoutOnResume();

      if (shouldLogout && mounted) {
        // Stop monitoring BEFORE navigating to login
        SessionTimeoutService.stopMonitoring();

        // Wait a bit to ensure any ongoing operations complete
        await Future.delayed(const Duration(milliseconds: 300));

        if (!mounted) return;

        // Close any open dialogs/modals before navigating
        Navigator.of(
          context,
          rootNavigator: true,
        ).popUntil((route) => route.isFirst);

        // Small delay after closing modals
        await Future.delayed(const Duration(milliseconds: 100));

        if (!mounted) return;

        // Check if biometric is enabled
        final hasBiometric =
            await LocalStorageService.getBool('pref_biometric_fingerprint') ??
            false;
        final hasFaceId =
            await LocalStorageService.getBool('pref_biometric_faceid') ?? false;

        if (hasBiometric || hasFaceId) {
          context.go('/biometric-login');
        } else {
          context.go('/signin');
        }
      } else {
        // Just record activity if no logout needed
        SessionTimeoutService.recordActivity();
      }
    }
  }

  void _checkAndShowModals() async {
    if (_hasShownPasscodePrompt) return;

    final user = ref.read(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;
    final hasPasscode = user?.isPasscodeSet ?? false;

    // Check if biometric is already enabled
    final hasBiometric =
        await LocalStorageService.getBool('pref_biometric_fingerprint') ??
        false;
    final hasFaceId =
        await LocalStorageService.getBool('pref_biometric_faceid') ?? false;
    final biometricEnabled = hasBiometric || hasFaceId;

    // Check if user skipped biometric setup and if 1 month has passed
    final biometricSkippedTime = await LocalStorageService.get(
      'biometric_skipped_timestamp',
    );
    final shouldShowBiometric = _shouldShowBiometricPrompt(
      biometricSkippedTime,
    );

    // Check if device actually supports biometrics
    bool deviceSupportsBiometrics = false;
    try {
      final localAuth = LocalAuthentication();
      final canCheck = await localAuth.canCheckBiometrics;
      final availableBiometrics = await localAuth.getAvailableBiometrics();

      debugPrint('🔐 Biometric Check:');
      debugPrint('   canCheckBiometrics: $canCheck');
      debugPrint('   availableBiometrics: $availableBiometrics');
      debugPrint('   isEmpty: ${availableBiometrics.isEmpty}');

      deviceSupportsBiometrics = canCheck && availableBiometrics.isNotEmpty;
      debugPrint('   deviceSupportsBiometrics: $deviceSupportsBiometrics');
    } catch (e) {
      debugPrint('⚠️ Biometric check failed: $e');
      // If check fails, assume no biometric support
      deviceSupportsBiometrics = false;
    }

    _hasShownPasscodePrompt = true;

    // Priority 1: Show KYC modal if BVN not verified
    if (!isBvnVerified) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _showKycVerificationModal();
        }
      });
    }
    // Priority 2: Show Passcode modal if BVN verified but no passcode
    else if (!hasPasscode) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _showPasscodeSetupModal();
        }
      });
    }
    // Priority 3: Show Biometric modal ONLY if device supports it
    else if (!biometricEnabled &&
        shouldShowBiometric &&
        deviceSupportsBiometrics) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _showBiometricSetupModal();
        }
      });
    }
  }

  /// Check if biometric prompt should be shown (1 month since last skip)
  bool _shouldShowBiometricPrompt(String? skippedTimestamp) {
    if (skippedTimestamp == null) return true; // Never skipped, show it

    try {
      final skippedTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(skippedTimestamp),
      );
      final now = DateTime.now();
      final difference = now.difference(skippedTime);

      // Show again after 30 days (1 month)
      return difference.inDays >= 30;
    } catch (e) {
      return true; // If error parsing, show the prompt
    }
  }

  void _showKycVerificationModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _KycVerificationModal(
            onComplete: () async {
              Navigator.pop(context);
              // After KYC modal is closed, check if we need to show passcode modal
              final user = ref.read(userProvider);
              final hasPasscode = user?.isPasscodeSet ?? false;
              if (!hasPasscode) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    _showPasscodeSetupModal();
                  }
                });
              } else {
                // Check if biometric is enabled
                final hasBiometric =
                    await LocalStorageService.getBool(
                      'pref_biometric_fingerprint',
                    ) ??
                    false;
                final hasFaceId =
                    await LocalStorageService.getBool(
                      'pref_biometric_faceid',
                    ) ??
                    false;
                if (!hasBiometric && !hasFaceId) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      _showBiometricSetupModal();
                    }
                  });
                }
              }
            },
          ),
    );
  }

  void _showPasscodeSetupModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _PasscodeSetupModal(
            onComplete: () async {
              Navigator.pop(context);
              // After passcode modal is closed, check if we need to show biometric modal
              final hasBiometric =
                  await LocalStorageService.getBool(
                    'pref_biometric_fingerprint',
                  ) ??
                  false;
              final hasFaceId =
                  await LocalStorageService.getBool('pref_biometric_faceid') ??
                  false;
              if (!hasBiometric && !hasFaceId) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    _showBiometricSetupModal();
                  }
                });
              }
            },
          ),
    );
  }

  void _showBiometricSetupModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _BiometricSetupModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => SessionTimeoutService.recordActivity(),
      onPanDown: (_) => SessionTimeoutService.recordActivity(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }
}

/// ---------- KYC Verification Modal ----------
class _KycVerificationModal extends StatelessWidget {
  final VoidCallback onComplete;

  const _KycVerificationModal({Key? key, required this.onComplete})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Verification Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: appTheme.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  size: 40,
                  color: appTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Complete Your KYC',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Verify your identity to unlock all features and increase your transaction limits',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Benefits List
              _KycBenefitItem(
                icon: Icons.check_circle,
                text: 'Higher transaction limits',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _KycBenefitItem(
                icon: Icons.check_circle,
                text: 'Access to all payment features',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _KycBenefitItem(
                icon: Icons.check_circle,
                text: 'Secure and verified account',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _KycBenefitItem(
                icon: Icons.check_circle,
                text: 'Faster withdrawals and transfers',
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Verify Now Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BVNPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Verify Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Skip Button
              TextButton(
                onPressed: onComplete,
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KycBenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _KycBenefitItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: appTheme.primaryColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------- Passcode Setup Modal ----------
class _PasscodeSetupModal extends StatelessWidget {
  final VoidCallback? onComplete;

  const _PasscodeSetupModal({Key? key, this.onComplete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lock Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: appTheme.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: appTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Secure Your Account',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Set up a passcode to keep your account safe and secure',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Benefits List
              _BenefitItem(
                icon: Icons.check_circle,
                text: 'Protect your personal information',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _BenefitItem(
                icon: Icons.check_circle,
                text: 'Quick and easy access',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _BenefitItem(
                icon: Icons.check_circle,
                text: 'Enhanced security features',
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Set Up Passcode Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/create-passcode');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Set Up Passcode',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Skip Button
              TextButton(
                onPressed: () {
                  if (onComplete != null) {
                    onComplete!();
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------- Biometric Setup Modal ----------
class _BiometricSetupModal extends StatelessWidget {
  const _BiometricSetupModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fingerprint Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: appTheme.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 40,
                  color: appTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Enable Biometric Login',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Use your fingerprint or Face ID for quick and secure access to your account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Benefits List
              _BenefitItem(
                icon: Icons.check_circle,
                text: 'Quick and convenient login',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _BenefitItem(
                icon: Icons.check_circle,
                text: 'Enhanced security for your account',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _BenefitItem(
                icon: Icons.check_circle,
                text: 'No need to remember passwords',
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Enable Biometric Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/login-settings');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Enable Biometric',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Skip Button
              TextButton(
                onPressed: () async {
                  // Save timestamp when user skips
                  final timestamp =
                      DateTime.now().millisecondsSinceEpoch.toString();
                  await LocalStorageService.save(
                    'biometric_skipped_timestamp',
                    timestamp,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _BenefitItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: appTheme.primaryColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
