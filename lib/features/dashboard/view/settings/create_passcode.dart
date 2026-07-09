import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/controller/passcode_controller.dart';
import 'package:valarpay/core/services/secure_storage_service.dart';
import 'package:valarpay/core/services/session_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/features/models/create_passcode_request.dart';
import 'package:valarpay/features/notifiers/passcode_notifier.dart';
import 'package:valarpay/features/models/login.dart';
import 'package:valarpay/features/models/user.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class CreatePasscodeScreen extends ConsumerStatefulWidget {
  const CreatePasscodeScreen({super.key});

  @override
  ConsumerState<CreatePasscodeScreen> createState() =>
      _CreatePasscodeScreenState();
}

class _CreatePasscodeScreenState extends ConsumerState<CreatePasscodeScreen> {
  final int _passcodeLength = 6;
  bool _isConfirming = false;
  bool _isSaving = false;

  Future<void> _savePasscodeToBackend(String passcode) async {
    setState(() => _isSaving = true);

    try {
      final request = CreatePasscodeRequest(passcode: passcode);
      final notifier = ref.read(passcodeNotifierProvider.notifier);

      await notifier.createPasscode(request);

      final state = ref.read(passcodeNotifierProvider);

      if (mounted) {
        if (state.isDataAvailable) {
          // 🔐 Save passcode securely for biometric login
          await SecureStorageService.savePasscode(passcode);
          final username = await SessionService.getUsername();
          if (username != null) {
            await SecureStorageService.saveUsername(username);
          }

          AppMessenger.show(
            context,
            message: state.message ?? 'Passcode created successfully!',
            type: MessageType.success,
          );

          // Clear passcode controller
          ref.read(passcodeControllerProvider.notifier).clearAllPasscodes();

          // Navigate back to dashboard BEFORE updating the user state
          if (mounted) {
            context.pop();
          }

          // Update local state IMMEDIATELY (this will trigger the KYC modal on the dashboard)
          final currentUser = ref.read(userProvider);
          if (currentUser != null) {
            final jsonMap = currentUser.toJson();
            jsonMap['isPasscodeSet'] = true;
            jsonMap['is_passcode_set'] = true;
            final overrideUser = UserModel.fromJson(jsonMap);
            ref.read(userProvider.notifier).setUser(overrideUser);
          }

          // Refresh user profile and update state properly
          try {
            await Future.delayed(const Duration(milliseconds: 1500));
            final updatedUser = await ref.read(userNotifierProvider.notifier).refreshUserProfile();

            if (updatedUser != null) {
              UserModel finalUser = updatedUser;
              if (!updatedUser.isPasscodeSet) {
                 final jsonMap = updatedUser.toJson();
                 jsonMap['isPasscodeSet'] = true;
                 jsonMap['is_passcode_set'] = true;
                 finalUser = UserModel.fromJson(jsonMap);
              }

              ref.read(userProvider.notifier).setUser(finalUser);

              final currentToken = await SessionService.getAccessToken();
              if (currentToken != null) {
                await SessionService.saveSession(
                  LoginResponse(
                    user: finalUser,
                    accessToken: currentToken,
                    message: 'Success',
                    statusCode: 200,
                  ),
                );
              }
            }
          } catch (e) {
            debugPrint('Error refreshing profile: $e');
          }
        } else {
          AppMessenger.show(
            context,
            message: state.message ?? 'Failed to create passcode',
            type: MessageType.error,
          );

          // Reset and start over
          ref.read(passcodeControllerProvider.notifier).clearAllPasscodes();
          setState(() => _isConfirming = false);
        }
      }
    } catch (e) {
      if (mounted) {
        AppMessenger.show(
          context,
          message: 'Failed to create passcode: ${e.toString()}',
          type: MessageType.error,
        );

        // Reset and start over
        ref.read(passcodeControllerProvider.notifier).clearAllPasscodes();
        setState(() => _isConfirming = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _onNumberPressed(String number) {
    final passcodeNotifier = ref.read(passcodeControllerProvider.notifier);
    final passcodeState = ref.read(passcodeControllerProvider);

    if (!_isConfirming) {
      // Creating passcode
      if (passcodeState.passcode.length < _passcodeLength) {
        passcodeNotifier.updatePasscode(passcodeState.passcode + number);

        if (passcodeState.passcode.length + 1 == _passcodeLength) {
          // Move to confirmation step
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() => _isConfirming = true);
          });
        }
      }
    } else {
      // Confirming passcode
      if (passcodeState.confirmPasscode.length < _passcodeLength) {
        passcodeNotifier.updateConfirmPasscode(
          passcodeState.confirmPasscode + number,
        );

        if (passcodeState.confirmPasscode.length + 1 == _passcodeLength) {
          FocusScope.of(context).unfocus();

          // Check if passcodes match
          Future.delayed(const Duration(milliseconds: 300), () {
            if (passcodeNotifier.doPasscodesMatch()) {
              // Check passcode strength
              final strength = passcodeNotifier.getPasscodeStrength(
                passcodeState.passcode,
              );

              if (strength == PasscodeStrength.weak) {
                AppMessenger.show(
                  context,
                  message:
                      'Passcode is too weak. Please avoid simple patterns like 123456 or 111111.',
                  type: MessageType.warning,
                );
                // Reset and start over
                passcodeNotifier.clearAllPasscodes();
                setState(() => _isConfirming = false);
              } else {
                // Save passcode to backend
                _savePasscodeToBackend(passcodeState.passcode);
              }
            } else {
              AppMessenger.show(
                context,
                message: 'Passcodes do not match. Please try again.',
                type: MessageType.error,
              );
              // Reset both passcodes
              passcodeNotifier.clearAllPasscodes();
              setState(() => _isConfirming = false);
            }
          });
        }
      }
    }
  }

  void _onDeletePressed() {
    final passcodeNotifier = ref.read(passcodeControllerProvider.notifier);
    final passcodeState = ref.read(passcodeControllerProvider);

    if (!_isConfirming) {
      if (passcodeState.passcode.isNotEmpty) {
        passcodeNotifier.updatePasscode(
          passcodeState.passcode.substring(
            0,
            passcodeState.passcode.length - 1,
          ),
        );
      }
    } else {
      if (passcodeState.confirmPasscode.isNotEmpty) {
        passcodeNotifier.updateConfirmPasscode(
          passcodeState.confirmPasscode.substring(
            0,
            passcodeState.confirmPasscode.length - 1,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final passcodeState = ref.watch(passcodeControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                _isConfirming ? 'Confirm Passcode' : 'Create Passcode',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _isConfirming
                    ? 'Re-enter your 6-digit passcode'
                    : 'Create a 6-digit passcode to login',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Passcode dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_passcodeLength, (index) {
                  final currentPasscode =
                      _isConfirming
                          ? passcodeState.confirmPasscode
                          : passcodeState.passcode;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color:
                          index < currentPasscode.length
                              ? appTheme.primaryColor
                              : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              if (_isSaving)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),

              Expanded(
                 child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildNumberPad(),
                 ),
              ),

              if (_isConfirming)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextButton(
                    onPressed: () {
                      final passcodeNotifier = ref.read(
                        passcodeControllerProvider.notifier,
                      );
                      passcodeNotifier.clearAllPasscodes();
                      setState(() {
                        _isConfirming = false;
                      });
                    },
                    child: const Text(
                      'Start Over',
                      style: TextStyle(
                        color: appTheme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
            ],
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
          mainAxisSpacing: 20,
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
