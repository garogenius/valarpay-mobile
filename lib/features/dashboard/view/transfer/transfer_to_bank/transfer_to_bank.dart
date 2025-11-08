import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/core/widgets/snap_and_send_money.dart';
import 'package:valarpay/features/dashboard/view/transfer/transfer_to_bank/recent_and_saved_beneficiary.dart';
import 'package:valarpay/features/models/transfer_models.dart';
import 'package:valarpay/features/notifiers/transfer_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/features/dashboard/view/transfer/transfer_to_bank/select_bank_screen.dart';
import 'package:valarpay/core/widgets/camera_scan_account_screen.dart';
import 'package:valarpay/features/dashboard/view/transfer/transfer_to_bank/transfer_amount_screen.dart';

class TransferToBankScreen extends ConsumerStatefulWidget {
  const TransferToBankScreen({super.key});

  @override
  ConsumerState<TransferToBankScreen> createState() =>
      _TransferToBankScreenState();
}

class _TransferToBankScreenState extends ConsumerState<TransferToBankScreen> {
  final TextEditingController accountController = TextEditingController();
  Bank? selectedBank;
  AccountDetails? verifiedAccount;
  bool isVerifying = false;
  Timer? _debounce;
  bool _isDisposed = false;
  bool _shouldStopSearching = false;

  // Matching banks for entered account number
  List<Bank> matchedBanks = [];
  bool isSearchingBanks = false;
  String? matchError;
  @override
  void initState() {
    super.initState();

    // Fetch banks on screen init so matching can use the cached list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(banksNotifierProvider.notifier).fetchBanks(currency: 'NGN');
    });
    accountController.addListener(_onAccountNumberChanged);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _shouldStopSearching = true;
    _debounce?.cancel(); // cancel debounce
    accountController.removeListener(_onAccountNumberChanged);
    accountController.dispose();
    super.dispose();
  }

  Future<void> _searchMatchingBanks() async {
    if (_shouldStopSearching || _isDisposed) return;

    try {
      final accountNumber = accountController.text.trim();
      if (accountNumber.length != 10) return;
      _isDisposed = false;

      setState(() {
        isSearchingBanks = true;
        matchedBanks = [];
        matchError = null;
        verifiedAccount = null;
      });

      await ref
          .read(banksNotifierProvider.notifier)
          .fetchMatchedBanks(accountNumber: accountNumber);

      final banksState = ref.read(banksNotifierProvider);

      if (banksState.isDataAvailable && mounted) {
        setState(() {
          matchedBanks = banksState.singleData!.banks;
          selectedBank = banksState.singleData!.banks[0];
          verifiedAccount = banksState.singleData!.account;
          isSearchingBanks = false;
        });
      } else {
        setState(() {
          matchedBanks = [];
          selectedBank = null;
          verifiedAccount = null;
          isSearchingBanks = false;
          matchError = 'No matched bank found this account number';
        });
      }
    } catch (ex) {
      print('An error occured:$ex');
      setState(() {
        matchedBanks = [];
        selectedBank = null;
        verifiedAccount = null;
        isSearchingBanks = false;
        matchError =
            'No matched bank found, check the account number and ensure its correct or select the bank in the above';
      });
    }
  }

  void _verifyAccount() async {
    if (selectedBank == null || accountController.text.length != 10) return;

    setState(() {
      isVerifying = true;
      verifiedAccount = null;
    });

    try {
      await ref
          .read(accountVerificationNotifierProvider.notifier)
          .verifyAccount(
            accountNumber: accountController.text,
            bankCode: selectedBank!.bankCode,
          );
    } catch (e) {
      // Error handling is done in the listener
    } finally {
      setState(() {
        isVerifying = false;
      });
    }
  }

  void _onAccountNumberChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      if (_isDisposed) return;
      if (accountController.text.length == 10) {
        _searchMatchingBanks();
      } else {
        setState(() {
          verifiedAccount = null;
          matchedBanks = [];
          matchError = null;
        });
      }
    });
  }

  void _selectBank() async {
    final result = await Navigator.push<Bank>(
      context,
      MaterialPageRoute(builder: (context) => const SelectBankScreen()),
    );

    if (result != null) {
      setState(() {
        selectedBank = result;
        verifiedAccount = null;
        isSearchingBanks = false;
        matchedBanks = [];
        matchError = null;
      });
      if (accountController.text.length == 10) {
        _verifyAccount();
      }
    }
  }

  Future<void> pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        accountController.text = clipboardData.text!;
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;

    final accountVerificationState = ref.watch(
      accountVerificationNotifierProvider,
    );

    // Listen to account verification state
    ref.listen(accountVerificationNotifierProvider, (previous, next) {
      if (next.isDataAvailable && next.data != null && next.data!.isNotEmpty) {
        setState(() {
          verifiedAccount = next.data!.first;
        });
      } else if (next.isDataAvailable &&
          (next.data == null || next.data!.isEmpty)) {
        // API returned success but no data - account verification failed
        setState(() {
          verifiedAccount = null;
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
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Transfer to Bank Account",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body:
          !isBvnVerified
              ? const KycNotSetWidget(
                title: 'KYC Not Completed',
                subtitle:
                    'Complete your KYC verification to transfer money to bank accounts',
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SnapAndSendMoneyCard(
                        onPressed: () async {
                          final result = await Navigator.push<String?>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CameraScanScreen(),
                            ),
                          );
                          if (result != null && result.isNotEmpty) {
                            setState(() {
                              accountController.text = result;
                            });
                            if (accountController.text.length == 10) {
                              _searchMatchingBanks();
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      // Beneficiary Account Number
                      const Text(
                        "Beneficiary Account Number",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: accountController,
                        onChanged: (value) {
                          if (value.length == 10) {
                            _searchMatchingBanks();
                          }
                        },
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Enter Bank account name/number',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          suffixIcon:
                              accountController.text.isEmpty
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
                      const SizedBox(height: 20),

                      // Select Bank
                      if (matchedBanks.isEmpty)
                        const Text(
                          "Select Bank",
                          style: TextStyle(fontSize: 14),
                        ),
                      if (matchedBanks.isEmpty) const SizedBox(height: 8),
                      if (matchedBanks.isEmpty)
                        GestureDetector(
                          onTap: _selectBank,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).cardColor.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      selectedBank != null
                                          ? appTheme.primaryColor.withValues(
                                            alpha: 0.1,
                                          )
                                          : Colors.black,
                                  child:
                                      selectedBank != null
                                          ? Text(
                                            selectedBank!.name
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: appTheme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          )
                                          : const Icon(
                                            Icons.account_balance,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    selectedBank?.name ?? "Select Bank",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),

                      // If there are matched banks show them inline for user selection
                      if (isSearchingBanks)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Matching banks...'),
                            ],
                          ),
                        )
                      else if (matchedBanks.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              "Matched Bank(s)",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...matchedBanks.map((bank) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: appTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    child: Text(
                                      bank.name.substring(0, 2).toUpperCase(),
                                      style: TextStyle(
                                        color: appTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    bank.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedBank = bank;
                                      matchedBanks = [];
                                      matchError = null;
                                    });
                                    _verifyAccount();
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  tileColor: Theme.of(
                                    context,
                                  ).cardColor.withValues(alpha: 0.5),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      const SizedBox(height: 20),

                      // Account Verification Status / Match error
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
                      else if (matchError != null)
                        Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              matchError!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        )
                      else if (accountController.text.length == 10 &&
                          !isSearchingBanks &&
                          matchedBanks.isEmpty &&
                          verifiedAccount == null)
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

                      const SizedBox(height: 20),

                      // Continue Button
                      FullWidthButton(
                        text: 'Continue',
                        onPressed: () {
                          _isDisposed = true;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => TransferAmountScreen(
                                    selectedBank: selectedBank!,
                                    accountDetails: verifiedAccount!,
                                  ),
                            ),
                          );
                        },
                        isEnabled:
                            verifiedAccount != null && selectedBank != null,
                      ),
                      const SizedBox(height: 24),
                      TransferToBankRecentAndSavedBeneficiaries(
                        onSelectAccount: (selectedAccount) {
                          setState(() {
                            accountController.text = selectedAccount;
                          });
                          if (accountController.text.length == 10) {
                            _searchMatchingBanks();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
