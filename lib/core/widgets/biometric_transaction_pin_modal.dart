import 'package:flutter/material.dart';
import 'package:valarpay/core/services/biometric_auth_service.dart';
import 'package:valarpay/core/services/local_storage_service.dart';
import 'package:valarpay/core/services/secure_storage_service.dart';
import 'package:valarpay/core/services/biometric_transaction_tracker.dart';
import 'package:valarpay/core/utils/device_utils.dart';
import 'package:valarpay/core/constants/enums/enums.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';

class BiometricTransactionPinModal {
  /// Shows biometric first if enabled, only falls back to PIN if needed
  static Future<String?> show(BuildContext context) async {
    final fingerprintEnabled =
        await LocalStorageService.getBool('pref_transaction_fingerprint') ??
        false;
    final faceIdEnabled =
        await LocalStorageService.getBool('pref_transaction_faceid') ?? false;
    final genericBiometricEnabled =
        await LocalStorageService.getBool('pref_transaction_biometric') ??
        false;
    final biometricEnabled =
        genericBiometricEnabled || fingerprintEnabled || faceIdEnabled;

    if (!biometricEnabled) {
      // Biometrics not enabled → show PIN modal normally
      return await TransactionPinModal.show(context);
    }

    // Check if biometric is enabled for this device
    final currentDeviceId = await DeviceUtils.getDeviceId();
    final isEnabledForDevice =
        await SecureStorageService.isTransactionBiometricEnabledForDevice(
          currentDeviceId,
        );

    if (!isEnabledForDevice) {
      return await TransactionPinModal.show(context);
    }

    // Check if stored PIN exists
    final hasStoredPin = await SecureStorageService.hasWalletPin();
    if (!hasStoredPin) {
      return await TransactionPinModal.show(context);
    }

    //  Show only biometric dialog first
    final result = await _showBiometricDialogFirst(context);

    if (result == BiometricAuthResult.fallback) {
      // Biometric failed or user tapped "Use PIN Instead"
      return await TransactionPinModal.show(context);
    }

    return result; // Returns stored PIN if biometric succeeded
  }

  /// Show biometric dialog FIRST (no PIN shown unless fallback)
  static Future<String?> _showBiometricDialogFirst(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BiometricTransactionDialog(),
    );
  }
}

class _BiometricTransactionDialog extends StatefulWidget {
  @override
  _BiometricTransactionDialogState createState() =>
      _BiometricTransactionDialogState();
}

class _BiometricTransactionDialogState
    extends State<_BiometricTransactionDialog> {
  bool _showFallback = false;

  @override
  void initState() {
    // TODO: implement initState
    _authenticateWithBiometric();
    super.initState();
  }

  Future<void> _authenticateWithBiometric() async {
    if (!mounted) return;

    // Mark that transaction biometric is starting
    BiometricTransactionTracker.startTransactionBiometric();

    try {
      final result = await BiometricAuthService.authenticateWithFallback(
        promptMessage: 'Authenticate to authorize transaction',
      );

      // Clear the flag after biometric completes
      BiometricTransactionTracker.endTransactionBiometric();

      if (!mounted) return;

      if (result == BiometricAuthResult.success) {
        // Get stored wallet PIN
        final storedPin = await SecureStorageService.getWalletPin();

        if (storedPin != null && mounted) {
          Navigator.of(context).pop(storedPin);
        } else if (mounted) {
          // Stored PIN not found, show fallback
          setState(() {
            _showFallback = true;
          });
        }
      } else if (result == BiometricAuthResult.fallback) {
        // User chose to use PIN instead
        if (mounted) {
          setState(() {
            _showFallback = true;
          });
        }
      } else {
        // Authentication failed or cancelled
        if (mounted) {
          Navigator.of(context).pop(null);
        }
      }
    } catch (e) {
      // Clear flag on error
      BiometricTransactionTracker.endTransactionBiometric();

      if (!mounted) return;

      // Close modal on error
      Navigator.of(context).pop(null);
    }
  }

  Future<void> _showPinFallback() async {
    if (!mounted) return;

    // Close biometric dialog and return a special value to indicate fallback
    Navigator.of(context).pop('__FALLBACK__');
  }

  @override
  Widget build(BuildContext context) {
    if (_showFallback) {
      // Close this dialog and trigger fallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPinFallback();
      });
      return Container(); // Empty container while transitioning
    }

    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Biometric Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF76301).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fingerprint,
                size: 40,
                color: Color(0xFFF76301),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Authenticating...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Please wait while we verify your identity',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Show loading indicator when authenticating
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF76301)),
            ),
          ],
        ),
      ),
    );
  }
}
