import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/country_codes.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/utils/helpers.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/features/notifiers/international_airtime_notifier.dart';
import 'package:valarpay/features/models/international_airtime_models.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class CountryProviderScreen extends ConsumerStatefulWidget {
  final String countryName;
  final String countryIso;
  final String countryFlag;

  const CountryProviderScreen({
    super.key,
    required this.countryName,
    required this.countryIso,
    required this.countryFlag,
  });

  @override
  ConsumerState<CountryProviderScreen> createState() =>
      _CountryProviderScreenState();
}

class _CountryProviderScreenState extends ConsumerState<CountryProviderScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  
  InternationalAirtimePlan? _fetchedPlan;
  bool _isLoadingPlan = false;
  
  // FX Rate State
  InternationalFxRate? _currentFxRate;
  bool _isLoadingFx = false;
  Timer? _debounceTimer;

  String get _dialCode {
    String code = CountryCodes.getDialCode(widget.countryIso);
    if (code.isEmpty) {
      code = CountryCodes.getDialCode(widget.countryName);
    }
    return code;
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _phoneController.dispose();
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    final text = _amountController.text;
    if (text.isEmpty) {
        if (mounted) setState(() => _currentFxRate = null);
        return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
        _fetchFxRate();
    });
  }

  Future<void> _fetchFxRate() async {
    if (!mounted) return;
    if (_fetchedPlan == null) return;
    
    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    if (amount <= 0) {
        if (mounted) setState(() => _currentFxRate = null);
        return;
    }

    setState(() => _isLoadingFx = true);

    try {
      final fxRate = await ref.read(internationalAirtimeRepositoryProvider).getFxRate(
            amount,
            _fetchedPlan!.currencyCode,
            _fetchedPlan!.operatorId,
          );
      if (!mounted) return;
      
      setState(() {
          _currentFxRate = fxRate;
          _isLoadingFx = false;
      });
    } catch (e) {
        if (mounted) setState(() => _isLoadingFx = false);
    }
  }

  Future<void> _fetchPlan() async {
    if (!mounted) return;
    String phoneNumber = _phoneController.text.trim().replaceAll(RegExp(r'\s+|-'), '');
    if (phoneNumber.length < 5) return;

    setState(() {
      _isLoadingPlan = true;
      _fetchedPlan = null;
      _currentFxRate = null;
    });

    try {
      final fullPhoneNumber = _getNormalizedPhoneNumber(phoneNumber);
      await ref.read(internationalAirtimePlanProvider.notifier).getPlan(fullPhoneNumber);
      
      if (!mounted) return;

      final planState = ref.read(internationalAirtimePlanProvider);
      
      setState(() => _isLoadingPlan = false);

      if (planState.isDataAvailable && planState.data != null && planState.data!.isNotEmpty) {
        setState(() {
          _fetchedPlan = planState.data!.first;
        });
        // Trigger FX fetch if amount is already there
        if (_amountController.text.isNotEmpty) {
            _fetchFxRate();
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPlan = false);
    }
  }

  String _getNormalizedPhoneNumber(String phoneNumber) {
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+|-'), '');
    if (cleanPhone.isEmpty) return '';

    // If starts with +, it's already full
    if (cleanPhone.startsWith('+')) return cleanPhone;

    // Normalize dial code (remove hyphens, keep leading +)
    String cleanDialCode = _dialCode.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanDialCode.isEmpty) return cleanPhone;

    // Strip leading zero if present
    if (cleanPhone.startsWith('0')) {
      cleanPhone = cleanPhone.substring(1);
    }

    // Check if the number already starts with the dial code (without the +)
    // e.g. dial code is +44 and number is 447441...
    String dialCodeNoPlus = cleanDialCode.replaceAll('+', '');
    if (cleanPhone.startsWith(dialCodeNoPlus)) {
      return '+$cleanPhone';
    }

    return '$cleanDialCode$cleanPhone';
  }
  Future<void> _handleContinue() async {
    if (_phoneController.text.isEmpty) {
      AppMessenger.show(context, message: 'Please enter phone number', type: MessageType.error);
      return;
    }

    if (_fetchedPlan == null) {
      await _fetchPlan();
      if (_fetchedPlan == null) {
         final planState = ref.read(internationalAirtimePlanProvider);
         AppMessenger.show(
           context, 
           message: planState.message ?? 'Failed to identify operator. Please check the number.', 
           type: MessageType.error
         );
         return;
      }
    }
    
    if (_amountController.text.isEmpty) {
      AppMessenger.show(context, message: 'Please select or enter amount', type: MessageType.error);
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    if (amount <= 0) {
      AppMessenger.show(context, message: 'Invalid amount', type: MessageType.error);
      return;
    }
    
    if (_fetchedPlan != null) {
        if (_fetchedPlan!.minAmount > 0 && amount < _fetchedPlan!.minAmount) {
             AppMessenger.show(context, message: 'Minimum amount is ${_fetchedPlan!.minAmount}', type: MessageType.error);
             return;
        }
        if (_fetchedPlan!.maxAmount > 0 && amount > _fetchedPlan!.maxAmount) {
             AppMessenger.show(context, message: 'Maximum amount is ${_fetchedPlan!.maxAmount}', type: MessageType.error);
             return;
        }
    }

    setState(() => _isLoadingPlan = true);

    try {
      await ref.read(internationalFxRateProvider.notifier).getFxRate(amount, _fetchedPlan!.currencyCode, _fetchedPlan!.operatorId);

      if (!mounted) return;
      setState(() => _isLoadingPlan = false);

      final fxState = ref.read(internationalFxRateProvider);
      if (!fxState.isDataAvailable || fxState.data == null || fxState.data!.isEmpty) {
        AppMessenger.show(context, message: fxState.message ?? 'Failed to get FX rate', type: MessageType.error);
        return;
      }

      final fxRate = fxState.data!.first;
      
      final fullPhoneNumber = _getNormalizedPhoneNumber(_phoneController.text.trim());

      _navigateToDetails(fxRate, fullPhoneNumber, _fetchedPlan!);
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingPlan = false);
      AppMessenger.show(context, message: e.toString(), type: MessageType.error);
    }
  }

  void _navigateToDetails(InternationalFxRate fxRate, String fullPhoneNumber, InternationalAirtimePlan plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReuseableTransactionDetailsScreen(
          totalAmount: fxRate.convertedAmount,
          hasBottom: false,
          saveBeneficiary: false,
          topTitleText: 'Transaction Information',
          topTransactionsDetailsList: [
            buildDetailRow('Recipient', fullPhoneNumber, isDark),
            buildDetailRow('Operator', plan.operatorName, isDark),
            buildDetailRow('Amount', '${fxRate.fromCurrency} ${fxRate.amount}', isDark),
            buildDetailRow('FX Rate', '1 ${fxRate.fromCurrency} = ${fxRate.rate.toStringAsFixed(4)} ${fxRate.toCurrency}', isDark),
            buildDetailRow('Payable Amount', '${currencyFormatter(fxRate.convertedAmount.toStringAsFixed(2))}', isDark),
          ],
          onButtonPressed: () => _handlePin(fxRate, fullPhoneNumber, plan, biometric: false),
          onBiometricButtonPressed: () => _handlePin(fxRate, fullPhoneNumber, plan, biometric: true),
          onAutomaticallyShowBiometric: () => _handlePin(fxRate, fullPhoneNumber, plan, biometric: true),
          onSaveBeneficiaryChanged: (val) { },
        ),
      ),
    );
  }

  Future<void> _handlePin(
    InternationalFxRate fxRate, 
    String fullPhoneNumber, 
    InternationalAirtimePlan plan, 
    {bool biometric = false}
  ) async {
    final pin = biometric
        ? await BiometricTransactionPinModal.show(context)
        : await TransactionPinModal.show(context);

    if (pin == null || pin.length != 4) return;
    
    if (!mounted) return;
    Navigator.pop(context);

    try {
      final request = InternationalAirtimePurchaseRequest(
        amount: fxRate.amount,
        operatorId: plan.operatorId,
        phone: fullPhoneNumber,
        currency: fxRate.fromCurrency,
        walletPin: pin,
        addBeneficiary: false,
      );

      await ref.read(internationalAirtimePurchaseProvider.notifier).purchase(request);

      if (!mounted) return;

      final purchaseState = ref.read(internationalAirtimePurchaseProvider);
      if (purchaseState.isDataAvailable && purchaseState.data != null && purchaseState.data!.isNotEmpty) {
        _navigateToReceipt(purchaseState.data!.first);
      } else {
        AppMessenger.show(context, message: purchaseState.message ?? 'Purchase failed', type: MessageType.error);
      }
    } catch (e) {
      if (!mounted) return;
      AppMessenger.show(context, message: e.toString(), type: MessageType.error);
    }
  }

  void _navigateToReceipt(InternationalAirtimePurchaseResponse response) {
    final now = DateTime.now();
    final receiptData = [
      ShareableTransactionReceiptDetail(label: 'Amount Paid', value: currencyFormatter(response.amount.toStringAsFixed(2))),
      ShareableTransactionReceiptDetail(label: 'Recipient', value: response.recipient),
      ShareableTransactionReceiptDetail(label: 'Operator', value: response.operator),
      ShareableTransactionReceiptDetail(label: 'Transaction Ref', value: response.transactionRef),
      ShareableTransactionReceiptDetail(label: 'Status', value: 'Successful', isSuccessful: true),
    ];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionReceiptWidget(
          headerText: 'Transaction Successful',
          amount: response.amount.toStringAsFixed(2),
          topDetails: [
            TransactionDetail(label: 'Transaction ID', value: response.transactionRef, showCopyIcon: true),
            TransactionDetail(label: 'Recipient', value: response.recipient),
            TransactionDetail(label: 'Operator', value: response.operator),
          ],
          shareableDetails: receiptData,
          receiptDate: '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = appTheme.primaryColor;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey[50], 
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.countryFlag.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SvgPicture.network(
                    widget.countryFlag,
                    width: 32,
                    height: 24,
                    fit: BoxFit.cover,
                    placeholderBuilder: (_) => const SizedBox(width: 32, height: 24),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Flexible(
               child: Text(
                 widget.countryName,
                 style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: isDark ? Colors.white : Colors.black),
                 overflow: TextOverflow.ellipsis,
               ),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_fetchedPlan != null && _fetchedPlan!.operatorName.isNotEmpty) ...[
                Center(
                  child: Column(
                    children: [
                      if (_fetchedPlan!.logoUrl != null && _fetchedPlan!.logoUrl!.isNotEmpty)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amber, width: 2), // Gold border as seen in screenshot
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              _fetchedPlan!.logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.rss_feed, size: 40, color: themeColor),
                            ),
                          ),
                        )
                      else
                        Icon(Icons.rss_feed, size: 60, color: themeColor),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        _fetchedPlan!.operatorName,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
            ],

            Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 8),
            
            Container(
              decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        child: Text(
                            _dialCode,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                        ),
                    ),
                    VerticalDivider(color: isDark ? Colors.white12 : Colors.grey.shade300, width: 1, indent: 8, endIndent: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
                        cursorColor: themeColor,
                        onChanged: (val) {
                           if (val.length >= 7) {
                              _fetchPlan();
                           } else {
                               if (_fetchedPlan != null) {
                                   setState(() {
                                      _fetchedPlan = null;
                                      _currentFxRate = null;
                                   });
                               }
                           }
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          suffixIcon: _isLoadingPlan 
                              ? Transform.scale(scale: 0.5, child: const CircularProgressIndicator(strokeWidth: 3)) 
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            

            
            const SizedBox(height: 32),
            
            Text('Amount (Foreign Currency)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 12),

            if (_fetchedPlan != null && _fetchedPlan!.fixedAmounts.isNotEmpty)
                 GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.2,
                    ),
                    itemCount: _fetchedPlan!.fixedAmounts.length,
                    itemBuilder: (context, index) {
                        final amt = _fetchedPlan!.fixedAmounts[index];
                        final isSelected = _amountController.text == amt.toString();
                        return GestureDetector(
                            onTap: () {
                                setState(() {
                                    _amountController.text = amt.toString();
                                });
                            },
                            child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                    color: isSelected ? themeColor : (isDark ? const Color(0xFF1F1F1F) : Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: isSelected ? themeColor : (isDark ? Colors.white12 : Colors.grey.shade300),
                                        width: isSelected ? 0 : 1
                                    ),
                                    boxShadow: isSelected ? [BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : null
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                    '$amt',
                                    style: TextStyle(
                                        color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15
                                    ),
                                ),
                            ),
                        );
                    },
                 )
            else
                 Container(
                     decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                     ),
                     child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black),
                        cursorColor: themeColor,
                        decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            suffixIcon: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Text('Global', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)), 
                            ),
                        ),
                    ),
                ),
            
            const SizedBox(height: 16),
            if (_isLoadingFx)
                Row(
                    children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: themeColor)),
                        const SizedBox(width: 8),
                        Text('Calculating exchange rate...', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey)),
                    ],
                )
            else if (_currentFxRate != null)
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: themeColor.withOpacity(0.2)),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text('Estimated Payment:', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
                            Text(
                                '${currencyFormatter(_currentFxRate!.convertedAmount.toStringAsFixed(2))}',
                                style: TextStyle(fontWeight: FontWeight.bold, color: themeColor, fontSize: 16),
                            ),
                        ],
                    ),
                ),
            
            const SizedBox(height: 48),
            
            FullWidthButton(
              text: 'Continue',
              onPressed: (_isLoadingPlan || _isLoadingFx) ? null : _handleContinue,
              isLoading: _isLoadingPlan,
            ),
            
            if (_fetchedPlan == null && !_isLoadingPlan && _phoneController.text.length > 5) ...[
                 const SizedBox(height: 20),
                 Center(
                     child: Text(
                         'Enter a valid number to see operators',
                         style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 13),
                     ),
                 ),
            ]
          ],
        ),
      ),
    );
  }
}
