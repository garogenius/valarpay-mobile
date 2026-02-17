import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/core/services/local_storage_service.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/providers/user_provider.dart';

Widget buildDetailRow(
  String label,
  String value,
  bool isDark, {
  bool isTotal = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 12,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            softWrap: true,
          ),
        ),
      ],
    ),
  );
}

class ReuseableTransactionDetailsScreen extends ConsumerStatefulWidget {
  final List<Widget> topTransactionsDetailsList;
  final String topTitleText;
  bool hasBottom;
  String? bottomTitleText;
  final List<Widget>? bottomTransactionsDetailsList;
  final Function()? onButtonPressed;
  final Function()? onBiometricButtonPressed;
  final Function()? onAutomaticallyShowBiometric;
  final bool showActions;
  bool saveBeneficiary;
  Function(bool) onSaveBeneficiaryChanged;
  final double totalAmount;

  ReuseableTransactionDetailsScreen({
    super.key,
    required this.topTransactionsDetailsList,
    this.bottomTransactionsDetailsList,
    required this.topTitleText,
    this.bottomTitleText,
    required this.hasBottom,
    this.onButtonPressed,
    this.onBiometricButtonPressed,
    this.showActions = true,
    required this.saveBeneficiary,
    required this.onSaveBeneficiaryChanged,
    required this.totalAmount,
    this.onAutomaticallyShowBiometric,
  });

  @override
  ConsumerState<ReuseableTransactionDetailsScreen> createState() =>
      _ReuseableTransactionDetailsScreenState();
}

class _ReuseableTransactionDetailsScreenState
    extends ConsumerState<ReuseableTransactionDetailsScreen> {
  String selectedPaymentMethod = 'ValarPay Account'; // Default selection
  late bool _saveBeneficiary;
  @override
  void initState() {
    super.initState();
    _saveBeneficiary = widget.saveBeneficiary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Get user data from provider
    final user = ref.watch(userProvider);
    final wallet =
        user?.wallets.isNotEmpty == true ? user!.wallets.first : null;
    final accountNumber = wallet?.accountNumber ?? '0000000000';
    final balance = wallet?.balance ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction details container
              Text(
                '${widget.topTitleText} Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: widget.topTransactionsDetailsList),
              ),
              if (widget.hasBottom) SizedBox(height: 24),
              if (widget.hasBottom)
                Text(
                  widget.bottomTitleText ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              if (widget.hasBottom) SizedBox(height: 16),

              if (widget.hasBottom)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: widget.bottomTransactionsDetailsList ?? [],
                  ),
                ),

              if (widget.showActions) ...[
                const SizedBox(height: 80),

                // Pay Via section
                Text(
                  'Pay Via',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment methods
                      _buildPaymentMethod(
                        'ValarPay Account',
                        accountNumber,
                        balance.toString(),
                        'assets/images/new_valapay.png',
                        isDark,
                      ),
                      // const SizedBox(height: 12),
                      // _buildPaymentMethod(
                      //   'First Bank of Nigeria',
                      //   '0000000000',
                      //   'assets/images/firstbank.png',
                      //   isDark,
                      // ),

                      // const SizedBox(height: 12),
                      // _buildPaymentMethod(
                      //   'Wema Bank',
                      //   '0000000000',
                      //   'assets/images/wema.png',
                      //   isDark,
                      // ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Save Beneficiary Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Save Beneficiary',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: _saveBeneficiary,
                      onChanged: (val) {
                        // Update local UI immediately
                        setState(() {
                          _saveBeneficiary = val;
                        });
                        // Notify parent as before
                        widget.onSaveBeneficiaryChanged(val);
                      },
                      activeColor: const Color(0xFFF76301),
                      activeTrackColor: const Color(
                        0xFFF76301,
                      ).withOpacity(0.3),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.withOpacity(0.3),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Confirm Button
                FullWidthButton(
                  text: 'Confirm',
                  onPressed: () {
                    if (balance < widget.totalAmount) {
                      AppMessenger.show(
                        context,
                        message:
                            'Insufficient account balance, kindly top up and continue',
                        type: MessageType.error,
                      );
                    } else {
                      showConfirmPaymentSheet(context);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(
    String name,
    String accountNumber,
    String accountBalance,
    String imagePath,
    bool isDark,
  ) {
    final isSelected = selectedPaymentMethod == name;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = name;
        });
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 12, top: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    accountNumber,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Balance: ${currencyFormatter(accountBalance)}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFFF76301) : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showConfirmPaymentSheet(BuildContext context) async {
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

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (biometricEnabled) {
            widget.onAutomaticallyShowBiometric?.call();
          }
        });
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20.w,
            right: 20.w,
            top: 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Back Icon
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Title
              Text(
                "Confirm Payment",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),

              SizedBox(height: 6.h),

              // Subtitle
              Text(
                "Please confirm that these details are correct before proceeding.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
              ),

              SizedBox(height: 20.h),

              // Proceed Button + Fingerprint
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FullWidthButton(
                      text: 'Proceed',
                      onPressed:
                          (widget.onButtonPressed != null)
                              ? widget.onButtonPressed!
                              : () {},
                    ),
                  ),

                  if (biometricEnabled) SizedBox(width: 14.w),

                  // Fingerprint Icon
                  if (biometricEnabled)
                    InkWell(
                      onTap:
                          (widget.onBiometricButtonPressed != null)
                              ? widget.onBiometricButtonPressed!
                              : () {},
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        child: const Icon(Icons.fingerprint, size: 26),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}
