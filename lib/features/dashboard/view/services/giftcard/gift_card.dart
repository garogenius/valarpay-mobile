import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/check_balance.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/current_rate_widget.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import 'package:valarpay/features/dashboard/view/services/giftcard/upload_images_screen.dart';
import 'package:valarpay/features/models/giftcard.dart';
import 'package:valarpay/features/notifiers/giftcard_notifier.dart';
import '/core/themes/color_utils.dart';
import '/features/dashboard/widgets/services_widgets/giftcard_widgets/gift_card_brand_modal.dart';
import '/features/dashboard/widgets/services_widgets/giftcard_widgets/gift_card_country_modal.dart';
import '/features/dashboard/widgets/services_widgets/giftcard_widgets/gift_card_amount_modal.dart';
import '/features/dashboard/view/services/giftcard/saved_beneficiary_screen.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class GiftCardScreen extends ConsumerStatefulWidget {
  const GiftCardScreen({super.key});

  @override
  ConsumerState<GiftCardScreen> createState() => _GiftCardScreenState();
}

class _GiftCardScreenState extends ConsumerState<GiftCardScreen> {
  bool _isBuySelected = true;
  GiftCardProduct? _selectedProduct;
  String _selectedBrand = 'Select Brand';
  String _selectedCountry = 'Select Country';
  String _selectedAmount = 'Select Amount';
  double? _selectedAmountValue;
  int _quantity = 1;
  String _codeOptional = '';
  String _currentRate = '0';
  List<GiftCardProduct> _availableProducts = [];
  List<GiftCardCategory> _categories = [];
  bool _isLoadingRate = false;
  bool _saveBeneficiary = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    ref.read(giftCardCategoriesNotifierProvider.notifier).getCategories();
    ref.read(giftCardNotifierProvider.notifier).getProducts(currency: 'NGN');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = user?.isBvnVerified ?? false;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final giftCardState = ref.watch(giftCardNotifierProvider);
    final categoriesState = ref.watch(giftCardCategoriesNotifierProvider);

    // Update available products when state changes
    if (giftCardState.isDataAvailable && giftCardState.data != null) {
      _availableProducts = giftCardState.data!;
    }

    // Update categories when state changes
    if (categoriesState.isDataAvailable && categoriesState.data != null) {
      _categories = categoriesState.data!;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Giftcards',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions:
            isBvnVerified
                ? [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => SavedBeneficiaryScreen(
                                onSelectBeneficiary: (beneficiary) {
                                  setState(() {
                                    _codeOptional = beneficiary.cardNumber;
                                  });
                                },
                              ),
                        ),
                      );
                    },
                    child: const Text(
                      'Saved Beneficiary',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ]
                : null,
      ),
      body:
          !isBvnVerified
              ? const KycNotSetWidget(
                title: 'KYC Not Completed',
                subtitle:
                    'Complete your KYC verification to buy or sell giftcards',
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Buy/Sell Toggle
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? const Color(0xFF2B2725)
                                  : Colors.grey[200],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap:
                                    () => setState(() => _isBuySelected = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _isBuySelected
                                            ? Colors.white
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    'Buy Giftcard',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          _isBuySelected
                                              ? Colors.black
                                              : Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap:
                                    () =>
                                        setState(() => _isBuySelected = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        !_isBuySelected
                                            ? Colors.white
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    'Sell Giftcard',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          !_isBuySelected
                                              ? Colors.black
                                              : Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Select Giftcard Brand
                      _buildSectionTitle('Select Giftcard Brand'),
                      const SizedBox(height: 8),
                      _buildDropdownField(
                        value:
                            giftCardState.isInitialLoading
                                ? 'Loading...'
                                : _selectedBrand,
                        imagePath:
                            _selectedProduct?.logoUrls.isNotEmpty == true
                                ? _selectedProduct!.logoUrls.first
                                : 'assets/images/blank.png',
                        onTap:
                            giftCardState.isInitialLoading
                                ? null
                                : () => _showGiftCardBrandModal(),
                        isLoading: giftCardState.isInitialLoading,
                      ),

                      const SizedBox(height: 14),

                      if (_selectedProduct != null && _isBuySelected)
                        InkWell(
                          onTap: () {
                            _showRedemeptionDetails(context);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.info_outline),
                              SizedBox(width: 10),
                              Text('Tap to view redemption instructions'),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Select Country
                      _buildSectionTitle('Select Country'),
                      const SizedBox(height: 8),
                      _buildDropdownField(
                        value: _selectedCountry,
                        imagePath:
                            _selectedProduct?.country.flagUrl ??
                            'assets/images/blank.png',
                        onTap:
                            _selectedProduct != null
                                ? () => _showCountryModal()
                                : null,
                        isLoading: false,
                      ),

                      const SizedBox(height: 20),

                      // Amount
                      _buildSectionTitle('Amount'),
                      const SizedBox(height: 8),
                      _buildDropdownField(
                        value:
                            _isLoadingRate
                                ? 'Loading rate...'
                                : _selectedAmount,
                        imagePath: 'assets/images/moneysymbol.png',
                        onTap:
                            _selectedProduct != null && !_isLoadingRate
                                ? () => _showAmountModal()
                                : null,
                        isLoading: _isLoadingRate,
                      ),

                      const SizedBox(height: 20),

                      // Enter Code (Optional)
                      _buildSectionTitle('Enter Code (Optional)'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          onChanged:
                              (value) => setState(() => _codeOptional = value),
                          decoration: InputDecoration(
                            hintText: '1234',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Price in Naira
                      CurrentRateWidget(
                        price: _currentRate,
                        text: 'Price in Naira',
                      ),

                      const SizedBox(height: 45),

                      // Continue Button
                      FullWidthButton(
                        text: 'Continue',
                        onPressed: _canProceed() ? _handleContinue : () {},
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String imagePath,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final country = _selectedCountry.toLowerCase();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (imagePath.startsWith('http'))
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.network(
                  imagePath,
                  height: 14,
                  width: 14,
                  errorBuilder:
                      (context, error, stackTrace) => ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.asset(
                          country == 'nigeria'
                              ? 'assets/images/ngflag.png'
                              : country == 'united states'
                              ? 'assets/images/USA.png'
                              : 'assets/images/blank.png',
                          height: 14,
                        ),
                      ),
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.asset(imagePath, height: 14),
              ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: onTap == null ? Colors.grey : null,
                ),
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down,
                color: onTap == null ? Colors.grey[400] : Colors.grey[600],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRedemeptionDetails(BuildContext context) async {
    if (_selectedProduct == null) return; // extra safety

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // lets sheet grow with content
      isDismissible: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, size: 24),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _selectedProduct?.brand.brandName ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Title / instructions
                  Text(
                    _selectedProduct?.redeemInstruction.verbose ??
                        'No redemption instructions found',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),

                  SizedBox(height: 14),

                  // Subtitle
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showGiftCardBrandModal() {
    if (_availableProducts.isEmpty) {
      AppMessenger.show(
        context,
        message: 'No gift card products available at the moment.',
        type: MessageType.info,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => GiftCardBrandModal(
            selectedBrand: _selectedBrand,
            products: _availableProducts,
            onBrandSelected: (product) {
              setState(() {
                _selectedProduct = product;
                _selectedBrand = product.brand.brandName;
                _selectedCountry = product.country.name;
                _selectedAmount = 'Select Amount';
                _selectedAmountValue = null;
                _currentRate = '0';
              });
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showCountryModal() {
    if (_selectedProduct == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => GiftCardCountryModal(
            selectedCountry: _selectedCountry,
            product: _selectedProduct!,
            onCountrySelected: (country) {
              setState(() {
                _selectedCountry = country;
              });
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showAmountModal() {
    if (_selectedProduct == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => GiftCardAmountModal(
            selectedAmount: _selectedAmount,
            product: _selectedProduct!,
            onAmountSelected: (amount, value) {
              setState(() {
                _selectedAmount = amount;
                _selectedAmountValue = value;
              });
              _updateRate(value);
              Navigator.pop(context);
            },
          ),
    );
  }

  void _updateRate(double amount) async {
    if (_selectedProduct == null) return;

    setState(() {
      _isLoadingRate = true;
    });

    try {
      final fxRate = await ref
          .read(giftCardNotifierProvider.notifier)
          .getFxRate(
            currency: _selectedProduct!.recipientCurrencyCode,
            amount: amount,
          );

      if (fxRate != null && mounted) {
        setState(() {
          _currentRate = fxRate.data.senderAmount.toStringAsFixed(2);
          _isLoadingRate = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentRate = '0';
          _isLoadingRate = false;
        });
      }
    }
  }

  bool _canProceed() {
    if (_isBuySelected) {
      return _selectedProduct != null &&
          _selectedAmountValue != null &&
          _currentRate != '0' &&
          !_isLoadingRate;
    } else {
      return _selectedProduct != null &&
          _selectedAmountValue != null &&
          _currentRate != '0' &&
          !_isLoadingRate;
    }
  }

  void _handleContinue() {
    if (_isBuySelected) {
      _handleBuyGiftCard();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadImagesScreen()),
      );
    }
  }

  void _handleBuyGiftCard() {
    if (_selectedProduct == null || _selectedAmountValue == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rate = _currentRate.replaceAll(',', '');
    final rateValue = double.tryParse(rate) ?? 0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReuseableTransactionDetailsScreen(
              totalAmount: double.parse(_currentRate),
              saveBeneficiary: _saveBeneficiary,
              onSaveBeneficiaryChanged: (value) {
                setState(() {
                  _saveBeneficiary = value;
                });
              },
              hasBottom: false,
              topTitleText: 'Transaction',
              topTransactionsDetailsList: [
                buildDetailRow('Card Type', _selectedBrand, isDark),
                buildDetailRow('Country', _selectedCountry, isDark),
                buildDetailRow('Card Amount', _selectedAmount, isDark),
                buildDetailRow(
                  'Rate',
                  '${currencyFormatter((rateValue / _selectedAmountValue!).toStringAsFixed(2))}/${_selectedProduct!.recipientCurrencyCode}',
                  isDark,
                ),
                buildDetailRow(
                  'Expected Amount in Naira',
                  currencyFormatter(_currentRate),
                  isDark,
                ),
              ],
              onButtonPressed: () => _handlePin(rateValue, biometric: false),
              onBiometricButtonPressed:
                  () => _handlePin(rateValue, biometric: true),
              onAutomaticallyShowBiometric:
                  () => _handlePin(rateValue, biometric: true),
            ),
      ),
    );
  }

  Future<void> _handlePin(double amount, {bool biometric = false}) async {
    final user = ref.read(userProvider);
    final hasEnoughBalance = checkBalanceLeft(
      context,
      user?.wallets.first.balance.toString() ?? '0',
      amount.toString(),
    );
    if (!hasEnoughBalance) return;

    final pin =
        biometric
            ? await BiometricTransactionPinModal.show(context)
            : await TransactionPinModal.show(context);

    if (pin == null || pin.length != 4 || !mounted) return;

    if (mounted) Navigator.pop(context);

    await _processPayment(pin, amount);
  }

  Future<void> _processPayment(String pin, double amount) async {
    // manual loader removed

    final paymentRequest = GiftCardPaymentRequest(
      productId: _selectedProduct!.productId,
      currency: 'NGN',
      walletPin: pin,
      amount: amount,
      unitPrice: _selectedAmountValue!,
      quantity: _quantity,
    );

    try {
      await ref
          .read(giftCardNotifierProvider.notifier)
          .payForGiftCard(paymentRequest);

      // manual loader removed

      if (!mounted) return;

      final state = ref.read(giftCardNotifierProvider);

      if (state.isDataAvailable &&
          state.data != null &&
          state.data!.isNotEmpty) {
        _navigateToReceipt(amount);
      } else {
        final errorMessage =
            state.message ?? 'Purchase failed. Please try again.';
        final isIncorrectPin =
            errorMessage.toLowerCase().contains('incorrect pin') ||
            errorMessage.toLowerCase().contains('wrong pin') ||
            errorMessage.toLowerCase().contains('invalid pin');

        AppMessenger.show(
          context,
          message:
              isIncorrectPin
                  ? 'Incorrect PIN. Please try again.'
                  : errorMessage,
          type: MessageType.error,
        );
      }
    } catch (e) {
      // manual loader removed
      if (!mounted) return;
      AppMessenger.show(
        context,
        message: 'Purchase failed: ${e.toString()}',
        type: MessageType.error,
      );
    }
  }

  void _navigateToReceipt(double amount) {
    final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final receiptDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} | ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    // Create receipt data while State is mounted
    final receiptData = [
      ShareableTransactionReceiptDetail(
        label: 'Amount',
        value: currencyFormatter(_currentRate),
      ),
      ShareableTransactionReceiptDetail(label: 'Currency', value: 'NGN'),
      ShareableTransactionReceiptDetail(
        label: 'Transaction Type',
        value: 'Buy Giftcard',
      ),
      ShareableTransactionReceiptDetail(
        label: 'Card Type',
        value: _selectedProduct != null ? _selectedProduct!.productName : '',
      ),
      ShareableTransactionReceiptDetail(
        label: 'Country',
        value: _selectedCountry,
      ),
      ShareableTransactionReceiptDetail(label: 'Card', value: 'Card number'),
      ShareableTransactionReceiptDetail(
        label: 'Transaction ID',
        value: transactionId,
      ),
      ShareableTransactionReceiptDetail(
        label: 'Status',
        value: 'Successful',
        isSuccessful: true,
      ),
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TransactionReceiptWidget(
              headerText: 'Transaction',
              amount: _currentRate,
              topDetails: [
                TransactionDetail(label: 'Card Type', value: _selectedBrand),
                TransactionDetail(label: 'Country', value: _selectedCountry),
                TransactionDetail(label: 'Card Amount', value: _selectedAmount),
                TransactionDetail(
                  label: 'Rate',
                  value:
                      '${currencyFormatter((amount / _selectedAmountValue!).toStringAsFixed(2))}/${_selectedProduct!.recipientCurrencyCode}',
                ),
                TransactionDetail(
                  label: 'Amount Paid',
                  value: currencyFormatter(_currentRate),
                ),
              ],
              bottomDetails: [
                TransactionDetail(
                  label: 'Transaction ID',
                  value: transactionId,
                  showCopyIcon: true,
                ),
                TransactionDetail(
                  label: 'Payment Source',
                  value: 'ValarPay Account',
                ),
                TransactionDetail(label: 'Date & Time', value: receiptDate),
              ],
              shareableDetails: receiptData,
              receiptDate: receiptDate,
            ),
      ),
    );
  }

  // Manual loader methods removed
}
