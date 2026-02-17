import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/services/local_storage_service.dart';
import 'package:valarpay/core/services/biometric_auth_service.dart';
import 'package:valarpay/core/services/secure_storage_service.dart';
import 'package:valarpay/core/services/biometric_transaction_tracker.dart';
import 'package:valarpay/core/utils/device_utils.dart';
import 'package:valarpay/core/constants/enums/enums.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
// import 'change_pin_screen.dart';

class TransactionPinSettingsScreen extends ConsumerStatefulWidget {
  const TransactionPinSettingsScreen({super.key});

  @override
  ConsumerState<TransactionPinSettingsScreen> createState() =>
      _TransactionPinSettingsScreenState();
}

class _TransactionPinSettingsScreenState
    extends ConsumerState<TransactionPinSettingsScreen> {
  bool fingerprintEnabled = false;
  bool faceIdEnabled = false;
  bool biometricEnabled = false;
  bool _loadingShown = false;

  static const _keyTransactionFingerprint = 'pref_transaction_fingerprint';
  static const _keyTransactionFaceId = 'pref_transaction_faceid';
  static const _keyTransactionBiometric = 'pref_transaction_biometric';

  // Device capability flags
  bool hasFingerprintAvailable = false;
  bool hasFaceAvailable = false;
  bool canCheckBiometrics = false;

  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkDeviceBiometrics();
    _loadBiometricPreferences();
  }

  Future<void> _checkDeviceBiometrics() async {
    try {
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      bool fingerprint = false;
      bool face = false;

      // Some devices (Android 11+) may report BiometricType.strong
      // instead of fingerprint or face.
      for (final bio in availableBiometrics) {
        if (bio == BiometricType.fingerprint || bio == BiometricType.strong) {
          fingerprint = true;
        }
        if (bio == BiometricType.face) {
          face = true;
        }
      }

      setState(() {
        canCheckBiometrics = canCheck && isDeviceSupported;
        hasFingerprintAvailable = fingerprint;
        hasFaceAvailable = face;
      });
    } catch (e) {
      debugPrint('Biometric check failed: $e');
    }
  }

  Future<void> _loadBiometricPreferences() async {
    final fp = await LocalStorageService.getBool(_keyTransactionFingerprint);
    final face = await LocalStorageService.getBool(_keyTransactionFaceId);
    final bio = await LocalStorageService.getBool(_keyTransactionBiometric);
    setState(() {
      fingerprintEnabled = fp ?? false;
      faceIdEnabled = face ?? false;
      biometricEnabled = bio ?? false;
    });
  }

  // ------------------- Loading Dialog Helpers -------------------
  void _showLoading() {
    if (_loadingShown) return;
    _loadingShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => WillPopScope(
            onWillPop: () async => false,
            child: const Center(child: CircularProgressIndicator()),
          ),
    );
  }

  void _hideLoading() {
    if (!_loadingShown) return;
    _loadingShown = false;
    
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final hasPinSet = user?.isWalletPinSet ?? false;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Transaction PIN Settings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction PIN Section,
            Text(
              'Transaction PIN',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (!hasPinSet)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF76301).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFFF76301),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please complete KYC and set your transaction pin first',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

            if (hasPinSet)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        context.push('/change-pin');
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Change PIN',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        context.push('/forgot-pin');
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Forgot PIN',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Biometrics Section
            Text(
              'Biometrics',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Use Fingerprint',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Switch(
                    value: fingerprintEnabled,
                    onChanged:
                        hasPinSet
                            ? (value) async {
                              await _handleFingerprintToggle(value);
                            }
                            : null,
                    activeTrackColor: appTheme.primaryColor,
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> _handleFingerprintToggle(bool value) async {
    if (value && !hasFingerprintAvailable) {
      AppMessenger.show(
        context,
        message: 'Fingerprint is not available on this device',
        type: MessageType.warning,
      );
      return;
    }
    if (value) {
      // Enabling - ask for wallet PIN first, then verify biometric
      final pin = await TransactionPinModal.show(context);
      if (pin == null || pin.length != 4) {
        AppMessenger.show(
          context,
          message: 'PIN entry cancelled',
          type: MessageType.warning,
        );
        return;
      }
      _showLoading();

      try {
        final isPinCorrect = await ref
            .read(userNotifierProvider.notifier)
            .verifyWalletPin(pin);

        _hideLoading();

        if (!mounted) return;

        if (!isPinCorrect) {
          AppMessenger.show(
            context,
            message: 'Incorrect PIN. Please try again.',
            type: MessageType.error,
          );
          return;
        }

        // PIN is correct - proceed with biometric
        // Mark biometric in progress
        BiometricTransactionTracker.startTransactionBiometric();

        // Verify with biometric (system UI will show)
        final result = await BiometricAuthService.authenticateWithFallback(
          promptMessage: 'Verify fingerprint to enable for transactions',
        );

        // Clear flag
        BiometricTransactionTracker.endTransactionBiometric();

        if (!mounted) return;

        if (result == BiometricAuthResult.success) {
          // Store wallet PIN securely
          await SecureStorageService.saveWalletPin(pin);

          // Save device ID
          final deviceId = await DeviceUtils.getDeviceId();
          await SecureStorageService.saveTransactionDeviceId(deviceId);

          // Save preference
          await LocalStorageService.saveBool(_keyTransactionFingerprint, true);

          setState(() {
            fingerprintEnabled = true;
          });

          AppMessenger.show(
            context,
            message: 'Fingerprint enabled for transactions on this device',
            type: MessageType.success,
          );
        } else {
          AppMessenger.show(
            context,
            message: 'Biometric verification failed',
            type: MessageType.error,
          );
        }
      } catch (e) {
        _hideLoading();
        
        if (!mounted) return;
        
        AppMessenger.show(
          context,
          message: 'An error occurred. Please try again.',
          type: MessageType.error,
        );
      }
    } else {
      // Disabling - verify with biometric first
      BiometricTransactionTracker.startTransactionBiometric();

      // ✅ No loading dialog - let system biometric UI show
      final result = await BiometricAuthService.authenticateWithFallback(
        promptMessage: 'Verify to disable fingerprint for transactions',
      );

      BiometricTransactionTracker.endTransactionBiometric();

      if (!mounted) return;

      if (result == BiometricAuthResult.success) {
        await LocalStorageService.saveBool(_keyTransactionFingerprint, false);

        setState(() {
          fingerprintEnabled = false;
        });

        AppMessenger.show(
          context,
          message: 'Fingerprint disabled for transactions',
          type: MessageType.success,
        );
      }
    }
  }

  Future<void> _handleFaceIdToggle(bool value) async {
    if (value && !hasFaceAvailable) {
      AppMessenger.show(
        context,
        message: 'Face ID is not available on this device',
        type: MessageType.warning,
      );
      return;
    }
    if (value) {
      // Enabling - ask for wallet PIN first, then verify biometric
      final pin = await TransactionPinModal.show(context);
      if (pin == null || pin.length != 4) {
        AppMessenger.show(
          context,
          message: 'PIN entry cancelled',
          type: MessageType.warning,
        );
        return;
      }

      _showLoading();

      try {
        final isPinCorrect = await ref
            .read(userNotifierProvider.notifier)
            .verifyWalletPin(pin);

        _hideLoading();

        if (!mounted) return;

        if (!isPinCorrect) {
          AppMessenger.show(
            context,
            message: 'Incorrect PIN. Please try again.',
            type: MessageType.error,
          );
          return;
        }

        // PIN is correct - proceed with biometric
        // Mark biometric in progress
        BiometricTransactionTracker.startTransactionBiometric();

        // Verify with biometric (system UI will show)
        final result = await BiometricAuthService.authenticateWithFallback(
          promptMessage: 'Verify Face ID to enable for transactions',
        );

        // Clear flag
        BiometricTransactionTracker.endTransactionBiometric();

        if (!mounted) return;

        if (result == BiometricAuthResult.success) {
          // Store wallet PIN securely
          await SecureStorageService.saveWalletPin(pin);

          // Save device ID
          final deviceId = await DeviceUtils.getDeviceId();
          await SecureStorageService.saveTransactionDeviceId(deviceId);

          // Save preference
          await LocalStorageService.saveBool(_keyTransactionFaceId, true);

          setState(() {
            faceIdEnabled = true;
          });

          AppMessenger.show(
            context,
            message: 'Face ID enabled for transactions on this device',
            type: MessageType.success,
          );
        } else {
          AppMessenger.show(
            context,
            message: 'Biometric verification failed',
            type: MessageType.error,
          );
        }
      } catch (e) {
        _hideLoading();
        
        if (!mounted) return;
        
        AppMessenger.show(
          context,
          message: 'An error occurred. Please try again.',
          type: MessageType.error,
        );
      }
    } else {
      // Disabling - verify with biometric first
      BiometricTransactionTracker.startTransactionBiometric();

      // ✅ No loading dialog - let system biometric UI show
      final result = await BiometricAuthService.authenticateWithFallback(
        promptMessage: 'Verify to disable Face ID for transactions',
      );

      BiometricTransactionTracker.endTransactionBiometric();

      if (!mounted) return;

      if (result == BiometricAuthResult.success) {
        await LocalStorageService.saveBool(_keyTransactionFaceId, false);

        setState(() {
          faceIdEnabled = false;
        });

        AppMessenger.show(
          context,
          message: 'Face ID disabled for transactions',
          type: MessageType.success,
        );
      }
    }
  }

  Future<void> _handleBiometricToggle(bool value) async {
    if (value && !canCheckBiometrics) {
      AppMessenger.show(
        context,
        message: 'Biometric is not available on this device',
        type: MessageType.warning,
      );
      return;
    }
    if (value) {
      // Enabling - ask for wallet PIN first, then verify biometric
      final pin = await TransactionPinModal.show(context);
      if (pin == null || pin.length != 4) {
        AppMessenger.show(
          context,
          message: 'PIN entry cancelled',
          type: MessageType.warning,
        );
        return;
      }
      _showLoading();

      try {
        final isPinCorrect = await ref
            .read(userNotifierProvider.notifier)
            .verifyWalletPin(pin);

        _hideLoading();

        if (!mounted) return;

        if (!isPinCorrect) {
          AppMessenger.show(
            context,
            message: 'Incorrect PIN. Please try again.',
            type: MessageType.error,
          );
          return;
        }

        // PIN is correct - proceed with biometric
        // Mark biometric in progress
        BiometricTransactionTracker.startTransactionBiometric();

        // Verify with biometric (system UI will show)
        final result = await BiometricAuthService.authenticateWithFallback(
          promptMessage: 'Verify biometric to enable for transactions',
        );

        // Clear flag
        BiometricTransactionTracker.endTransactionBiometric();

        if (!mounted) return;

        if (result == BiometricAuthResult.success) {
          // Store wallet PIN securely
          await SecureStorageService.saveWalletPin(pin);

          // Save device ID
          final deviceId = await DeviceUtils.getDeviceId();
          await SecureStorageService.saveTransactionDeviceId(deviceId);

          // Save preference
          await LocalStorageService.saveBool(_keyTransactionBiometric, true);

          setState(() {
            biometricEnabled = true;
          });

          AppMessenger.show(
            context,
            message: 'Biometric enabled for transactions on this device',
            type: MessageType.success,
          );
        } else {
          AppMessenger.show(
            context,
            message: 'Biometric verification failed',
            type: MessageType.error,
          );
        }
      } catch (e) {
        _hideLoading();
        
        if (!mounted) return;
        
        AppMessenger.show(
          context,
          message: 'An error occurred. Please try again.',
          type: MessageType.error,
        );
      }
    } else {
      // Disabling - verify with biometric first
      BiometricTransactionTracker.startTransactionBiometric();

      // ✅ No loading dialog - let system biometric UI show
      final result = await BiometricAuthService.authenticateWithFallback(
        promptMessage: 'Verify to disable biometric for transactions',
      );

      BiometricTransactionTracker.endTransactionBiometric();

      if (!mounted) return;

      if (result == BiometricAuthResult.success) {
        await LocalStorageService.saveBool(_keyTransactionBiometric, false);

        setState(() {
          biometricEnabled = false;
        });

        AppMessenger.show(
          context,
          message: 'Biometric disabled for transactions',
          type: MessageType.success,
        );
      }
    }
  }
}