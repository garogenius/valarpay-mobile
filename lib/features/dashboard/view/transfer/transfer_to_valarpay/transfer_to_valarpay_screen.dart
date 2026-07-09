import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/core/widgets/snap_and_send_money.dart';
import 'package:valarpay/core/widgets/camera_scan_account_screen.dart';
import 'package:valarpay/features/dashboard/view/transfer/transfer_to_valarpay/recent_and_saved_beneficiary.dart';
import 'package:valarpay/features/dashboard/view/transfer/transfer_to_valarpay/transfer_amount_screen.dart';
import 'package:valarpay/features/models/transfer_models.dart';
import 'package:valarpay/features/notifiers/transfer_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class TransferToValarPayScreen extends ConsumerStatefulWidget {
  const TransferToValarPayScreen({super.key});

  @override
  ConsumerState<TransferToValarPayScreen> createState() =>
      _TransferToValarPayScreenState();
}

class _TransferToValarPayScreenState
    extends ConsumerState<TransferToValarPayScreen> {
  final TextEditingController _accountController = TextEditingController();
  bool isEmpty = true;
  AccountDetails? verifiedAccount;
  bool isRecentTab = true;
  bool isVerifying = false;
  bool hasError = false;

  Future<void> pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _accountController.text = clipboardData.text!;
      });
      AppMessenger.show(
        context,
        type: MessageType.success,
        message: 'ValarPay pasted from clipboard',
      );
    } else {
      AppMessenger.show(
        context,
        type: MessageType.error,
        message: 'Clipboard is empty',
      );
    }
  }

  void _verifyAccount() async {
    if (_accountController.text.length != 10) return;

    setState(() {
      isVerifying = true;
      verifiedAccount = null;
      hasError = false;
    });

    try {
      await ref
          .read(internalAccountVerificationNotifierProvider.notifier)
          .verifyAccount(
            accountNumber: _accountController.text,
            bankCode: '090286',
          );
    } catch (e) {
      setState(() {
        hasError = true;
      });
      // Error handling is done in the listener
    } finally {
      setState(() {
        isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = (user?.isBvnVerified ?? false) || (user?.isNinVerified ?? false) || (user?.wallets.isNotEmpty ?? false);

    final accountVerificationState = ref.watch(
      internalAccountVerificationNotifierProvider,
    );

    // Listen to account verification state
    ref.listen(internalAccountVerificationNotifierProvider, (previous, next) {
      if (next.isDataAvailable && next.data != null && next.data!.isNotEmpty) {
        setState(() {
          verifiedAccount = next.data!.first;
          hasError = false;
        });
      } else if (next.isDataAvailable &&
          (next.data == null || next.data!.isEmpty)) {
        // API returned success but no data - account verification failed
        setState(() {
          verifiedAccount = null;
          hasError = true;
        });
      } else if (next.message != null && !next.isDataAvailable) {
        AppMessenger.show(
          context,
          message: next.message!,
          type: MessageType.error,
        );

        setState(() {
          verifiedAccount = null;
        });
      }
    });
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Transfer to ValarPay Account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body:
          !isBvnVerified
              ? const KycNotSetWidget(
                title: 'KYC Not Completed',
                subtitle:
                    'Complete your KYC verification to transfer money to ValarPay accounts',
              )
              : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt, color: Colors.blue, size: 18.sp),
                              SizedBox(width: 6),
                              Text(
                                'Quick, Free, No-delays',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        SnapAndSendMoneyCard(
                          onPressed: () async {
                            // Open camera scanner and await detected 10-digit account number
                            final result = await Navigator.push<String?>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CameraScanScreen(),
                              ),
                            );

                            if (result != null && result.isNotEmpty) {
                              // populate account field and trigger matching
                              setState(() {
                                _accountController.text = result;
                              });
                              // directly trigger matching for immediate feedback
                              if (_accountController.text.length == 10) {
                                _verifyAccount();
                              }
                            }
                          },
                        ),
                        SizedBox(height: 20),

                        Text(
                          'Recipient Account Number',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _accountController,
                          onChanged: (value) {
                            if (value.length == 10) {
                              _verifyAccount();
                            } else {
                              setState(() {
                                hasError = false;
                              });
                            }
                          },
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'Enter ValarPay account name/number',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                            suffixIcon:
                                _accountController.text.isEmpty
                                    ? IconButton(
                                      onPressed: () {
                                        pasteFromClipboard();
                                      },
                                      icon: Icon(
                                        Icons.content_paste,
                                        color: Colors.grey[500],
                                      ),
                                    )
                                    : null,
                            filled: true,
                            fillColor: Theme.of(
                              context,
                            ).cardColor.withValues(alpha: 0.5),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 14.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // Selected Recipient
                        if (isVerifying)
                          Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    appTheme.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Verifying account...",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          )
                        else if (verifiedAccount != null)
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: appTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  verifiedAccount!.accountName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: appTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else if (_accountController.text.length == 10 &&
                                !hasError ||
                            accountVerificationState.data == null && !hasError)
                          Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text(
                                "Account verification failed",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 25),

                        // Continue Button
                        FullWidthButton(
                          text: 'Continue',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => InternalTransferAmountScreen(
                                      accountDetails: verifiedAccount!,
                                    ),
                              ),
                            );
                          },
                          isEnabled: verifiedAccount != null,
                        ),
                        SizedBox(height: 25),
                        InternalRecentAndSavedBeneficiary(
                          onSelectAccount: (selectedAccount) {
                            // Populate the account controller and trigger matching
                            setState(() {
                              _accountController.text = selectedAccount;
                            });
                            if (_accountController.text.length == 10) {
                              _verifyAccount();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
