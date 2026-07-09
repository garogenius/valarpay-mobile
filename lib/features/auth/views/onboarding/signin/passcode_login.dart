import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/core/services/secure_storage_service.dart';
import 'package:valarpay/core/services/local_storage_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/utils/device_utils.dart';
import 'package:valarpay/features/notifiers/auth_notifier.dart';
import 'package:valarpay/features/models/login.dart';
import 'package:valarpay/features/auth/widgets/need_help_modal.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class PasscodeLoginScreen extends ConsumerStatefulWidget {
  const PasscodeLoginScreen({super.key});

  @override
  ConsumerState<PasscodeLoginScreen> createState() =>
      _PasscodeLoginScreenState();
}

class _PasscodeLoginScreenState extends ConsumerState<PasscodeLoginScreen> {
  String _passcode = '';
  final int _passcodeLength = 6;
  bool _isProcessing = false;

  void _onNumberPressed(String number) async {
    if (_passcode.length < _passcodeLength) {
      setState(() => _passcode += number);

      if (_passcode.length == _passcodeLength) {
        FocusScope.of(context).unfocus();
        setState(() => _isProcessing = true);

        final ip = await DeviceUtils.getIpAddress();
        final deviceName = await DeviceUtils.getDeviceName();
        final os = await DeviceUtils.getDeviceOS();

        final savedUsername = await SessionService.getUsername() ?? '';
        if (savedUsername != '') {
          final request = PasscodeLoginRequest(
            username: savedUsername,
            passcode: _passcode,
            ipAddress: ip,
            deviceName: deviceName,
            operatingSystem: os,
          );

          final notifier = ref.read(authNotifierProvider.notifier);
          await notifier.loginWithPasscode(request);
          final state = ref.read(authNotifierProvider);

          if (state.isDataAvailable && mounted) {
            final loginResponse = state.data?.first;
            await SessionService.saveSession(loginResponse!);
            ref.read(userProvider.notifier).setUser(loginResponse.user);
            await ref.read(userNotifierProvider.notifier).refreshUserProfile();

            await SecureStorageService.savePasscode(_passcode);
            await SecureStorageService.saveUsername(savedUsername);

            AppMessenger.show(
              context,
              message: 'Welcome ${loginResponse.user.fullname}',
              type: MessageType.success,
            );
            setState(() => _isProcessing = false);
            
            final userCurrency = loginResponse.user.currency ?? 'NGN';
            final hasCurrencyWallet = loginResponse.user.wallets.any((w) => w.currency == userCurrency);
            
            // Navigate after the current frame to avoid duplicate key issues
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (userCurrency != 'NGN' && !hasCurrencyWallet) {
                  context.pushReplacement('/account-setup', extra: userCurrency);
                } else if (userCurrency == 'NGN' && !hasCurrencyWallet) {
                  _showKycModal(context);
                } else {
                  context.go('/');
                }
              }
            });
          } else {
            if (!mounted) return;
            AppMessenger.show(
              context,
              message: state.message ?? 'Invalid passcode',
              type: MessageType.error,
            );
            setState(() => _passcode = '');
            setState(() => _isProcessing = false);
          }
        } else {
          AppMessenger.show(
            context,
            message: 'Please login with your password first.',
            type: MessageType.warning,
          );
          context.go('/signin');
        }
        setState(() => _isProcessing = false);
      }
    }
  }

  void _onDeletePressed() {
    if (_passcode.isNotEmpty) {
      setState(() => _passcode = _passcode.substring(0, _passcode.length - 1));
    }
  }

  Future<bool> _checkBiometricAvailable() async {
    final hasBiometric =
        await LocalStorageService.getBool('pref_biometric_fingerprint') ??
        false;
    final hasFaceId =
        await LocalStorageService.getBool('pref_biometric_faceid') ?? false;
    return hasBiometric || hasFaceId;
  }

  void _showKycModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevent dismissing by back button
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Identity Verification',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose your preferred method to verify your identity and open your NGN account',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pushReplacement('/bvn-verification');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Use BVN', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pushReplacement('/nin-verification');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: appTheme.primaryColor, width: 1.5),
                    ),
                  ),
                  child: const Text('Use NIN', style: TextStyle(color: appTheme.primaryColor)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/');
                },
                child: const Text('Do it later', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              Navigator.pop(context);
            } else {
              context.push('/signin');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          TextButton(
            onPressed: () => NeedHelpModal.show(context),
            child: const Text(
              'Need Help?',
              style: TextStyle(
                color: appTheme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
              const SizedBox(height: 10),
              const Text(
                'Enter Passcode',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your 6-digit passcode to login',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Passcode dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_passcodeLength, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color:
                          index < _passcode.length
                              ? appTheme.primaryColor
                              : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 30),

              _buildNumberPad(),

              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/forgot-password'),
                child: const Text(
                  'Forgot Passcode?',
                  style: TextStyle(
                    color: appTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Alternative Login Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    const Text(
                      'Or login with',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Biometric or Password Login Button
                    FutureBuilder<bool>(
                      future: _checkBiometricAvailable(),
                      builder: (context, snapshot) {
                        final bool isBiometricAvailable = snapshot.data == true;
                        
                        return Column(
                          children: [
                            if (isBiometricAvailable) ...[
                              Center(
                                child: TextButton.icon(
                                  onPressed: () => context.go('/biometric-login'),
                                  icon: const Icon(
                                    Icons.fingerprint,
                                    size: 20,
                                    color: appTheme.primaryColor,
                                  ),
                                  label: const Text(
                                    'Login with Biometric',
                                    style: TextStyle(
                                      color: appTheme.primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                               Center(
                                child: TextButton(
                                  onPressed: () => context.go('/signin'),
                                  child: const Text(
                                    'Login with Password',
                                    style: TextStyle(
                                      color: appTheme.primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildNumberPad() {
    final numbers = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '',
      '0',
      'del',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 20,
        ),
        itemCount: numbers.length,
        itemBuilder: (context, index) {
          final item = numbers[index];
          if (item.isEmpty) return const SizedBox.shrink();
          if (item == 'del') return _buildDeleteButton();
          return _buildNumberButton(item);
        },
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _onDeletePressed,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: const Center(child: Icon(Icons.backspace_outlined, size: 24)),
      ),
    );
  }
}
