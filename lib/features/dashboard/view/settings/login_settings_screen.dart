import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/core/services/local_storage_service.dart';
import 'package:valarpay/core/services/biometric_auth_service.dart';
import 'package:valarpay/core/services/secure_storage_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/device_utils.dart';
import 'package:valarpay/core/constants/enums/enums.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class LoginSettingsScreen extends ConsumerStatefulWidget {
  const LoginSettingsScreen({super.key});

  @override
  ConsumerState<LoginSettingsScreen> createState() =>
      _LoginSettingsScreenState();
}

class _LoginSettingsScreenState extends ConsumerState<LoginSettingsScreen> {
  static const _keyFingerprint = 'pref_biometric_fingerprint';
  static const _keyFaceId = 'pref_biometric_faceid';

  bool biometricEnabled = false;

  // Device capability flags
  BiometricType? availableBiometricType;
  String biometricLabel = 'Biometric';
  bool canCheckBiometrics = false;

  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkDeviceBiometrics();
    _loadPreferences();
  }

  Future<void> _checkDeviceBiometrics() async {
    try {
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;

      // Use platform-based labeling
      String label = 'Biometric';
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        label = 'Face ID';
      } else if (Theme.of(context).platform == TargetPlatform.android) {
        label = 'Fingerprint';
      }

      setState(() {
        canCheckBiometrics = canCheck && isDeviceSupported;
        biometricLabel = label;
      });
    } catch (e) {
      debugPrint('Biometric check failed: $e');
    }
  }

  Future<void> _loadPreferences() async {
    final fp = await LocalStorageService.getBool(_keyFingerprint);
    final face = await LocalStorageService.getBool(_keyFaceId);
    setState(() {
      // If either is enabled, biometric is enabled
      biometricEnabled = (fp ?? false) || (face ?? false);
    });
  }

  Future<void> _saveBiometricPref(bool value) async {
    // Save to both keys for backward compatibility
    if (availableBiometricType == BiometricType.face) {
      await LocalStorageService.saveBool(_keyFaceId, value);
      await LocalStorageService.saveBool(_keyFingerprint, false);
    } else {
      await LocalStorageService.saveBool(_keyFingerprint, value);
      await LocalStorageService.saveBool(_keyFaceId, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    final bool hasPasscodeCodeSet = user?.isPasscodeSet ?? false;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Login Settings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              // Password Section
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
                      onTap: () => context.push('/change-password'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Change Password',
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
                    const Divider(),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => context.push('/forgot-password'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Forgot Password',
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
                    const Divider(),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        hasPasscodeCodeSet
                            ? context.push('/change-passcode')
                            : context.push('/create-passcode');
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              hasPasscodeCodeSet
                                  ? 'Change Passcode'
                                  : 'Create Passcode',
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
                    const Divider(),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        context.push('/auto-logout-settings');
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Auto Logout Settings',
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

              const SizedBox(height: 20),

              // Biometrics Section
              Text(
                'Biometrics',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // Show biometric option only if device supports it
              if (canCheckBiometrics && availableBiometricType != null)
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
                          'Log in with $biometricLabel',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Switch(
                        value: biometricEnabled,
                        activeTrackColor: appTheme.primaryColor,
                        onChanged: (value) async {
                          // Check if passcode is set first
                          if (value && !hasPasscodeCodeSet) {
                            AppMessenger.show(
                              context,
                              message:
                                  'Please create a passcode first before enabling biometric login',
                              type: MessageType.warning,
                            );
                            // Navigate to create passcode
                            context.push('/create-passcode');
                            return;
                          }

                          // If enabling, verify with biometric first
                          if (value) {
                            final result =
                                await BiometricAuthService.authenticateWithFallback(
                                  promptMessage:
                                      'Verify $biometricLabel to enable',
                                );
                            if (result == BiometricAuthResult.success) {
                              // Save device ID to link biometric to this device
                              final deviceId = await DeviceUtils.getDeviceId();
                              await SecureStorageService.saveDeviceId(deviceId);

                              setState(() {
                                biometricEnabled = value;
                              });
                              _saveBiometricPref(value);
                              if (context.mounted) {
                                AppMessenger.show(
                                  context,
                                  message:
                                      '$biometricLabel login enabled for this device',
                                  type: MessageType.success,
                                );
                              }
                            } else if (result == BiometricAuthResult.fallback) {
                              if (context.mounted) {
                                AppMessenger.show(
                                  context,
                                  message:
                                      'Biometrics not available on this device',
                                  type: MessageType.warning,
                                );
                              }
                            } else {
                              if (context.mounted) {
                                AppMessenger.show(
                                  context,
                                  message: 'Authentication cancelled or failed',
                                  type: MessageType.error,
                                );
                              }
                            }
                          } else {
                            // Disabling requires authentication
                            final result =
                                await BiometricAuthService.authenticateWithFallback(
                                  promptMessage:
                                      'Verify to change biometric setting',
                                );
                            if (result == BiometricAuthResult.success) {
                              setState(() {
                                biometricEnabled = value;
                              });
                              _saveBiometricPref(value);
                              if (context.mounted) {
                                AppMessenger.show(
                                  context,
                                  message: '$biometricLabel login disabled',
                                  type: MessageType.success,
                                );
                              }
                            } else if (result == BiometricAuthResult.fallback) {
                              AppMessenger.show(
                                context,
                                message:
                                    'Biometrics not available. Please use your passcode to change settings',
                                type: MessageType.warning,
                              );
                            } else {
                              AppMessenger.show(
                                context,
                                message:
                                    'Authentication failed. Biometric setting unchanged',
                                type: MessageType.error,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Biometric authentication is not available on this device',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
