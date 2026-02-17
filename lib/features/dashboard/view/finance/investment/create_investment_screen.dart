import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/features/models/investment_models.dart';
import 'package:valarpay/features/notifiers/investment_notifier.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/features/auth/widgets/need_help_modal.dart';

class CreateInvestmentScreen extends ConsumerStatefulWidget {
  const CreateInvestmentScreen({super.key});

  @override
  ConsumerState<CreateInvestmentScreen> createState() => _CreateInvestmentScreenState();
}

class _CreateInvestmentScreenState extends ConsumerState<CreateInvestmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  InvestmentProduct? _product;
  PlatformFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(investmentProductNotifierProvider.notifier).fetchProductInfo();
      ref.read(userNotifierProvider.notifier).refreshUserProfile();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productState = ref.watch(investmentProductNotifierProvider);
    _product = productState.data?.firstOrNull;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
        ),
        title: const Text('Investment', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: _product == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF76301)))
          : _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userState = ref.watch(userNotifierProvider);
    final walletBalance = userState.data?.firstOrNull?.wallets.firstOrNull?.balance ?? 0;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Investment Amount
            Text('Investment Amount', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₦ ',
                prefixStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                hintText: NumberFormat('#,###').format(_product!.minimumInvestmentAmount),
                hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
                contentPadding: const EdgeInsets.all(18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                final amount = double.tryParse(value.replaceAll(',', ''));
                if (amount == null) return 'Invalid amount';
                if (amount < _product!.minimumInvestmentAmount) {
                  return 'Minimum investment is ₦${NumberFormat('#,###').format(_product!.minimumInvestmentAmount)}';
                }
                if (amount > walletBalance) return 'Insufficient balance';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Investment Tenure
            _buildReadOnlyField('Investment Tenure', '${_product!.tenureMonths} Months @ ${(_product!.roiRate * 100).toInt()}% ROI'),
            const SizedBox(height: 24),

            // Funding Account
            Text('Funding Account', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.account_balance_wallet, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Valarpay Wallet', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Balance: ₦${NumberFormat('#,###.##').format(walletBalance)}', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Legal Document Upload
            Text('Legal Document', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDocument,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _pickedFile != null ? Theme.of(context).primaryColor : (isDark ? Colors.white12 : Colors.grey.shade200),
                    width: _pickedFile != null ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _pickedFile != null ? Icons.description : Icons.cloud_upload_outlined, 
                      color: _pickedFile != null ? Theme.of(context).primaryColor : (isDark ? Colors.white38 : Colors.grey[400])
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pickedFile != null ? _pickedFile!.name : 'Upload Signed Agreement',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 14,
                              fontWeight: _pickedFile != null ? FontWeight.bold : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_pickedFile == null)
                            Text('PDF or Image (Max 5MB)', style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (_pickedFile != null)
                      GestureDetector(
                        onTap: () => setState(() => _pickedFile = null),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red.withOpacity(0.1),
                          child: const Icon(Icons.close, color: Colors.red, size: 14),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            _buildSubmitButton(() {
              if (_formKey.currentState?.validate() ?? false) {
                if (_pickedFile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please upload the signed legal document'), backgroundColor: Colors.red),
                  );
                  return;
                }
                _handleConfirm(); 
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
          ),
          child: Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }



  Widget _buildSubmitButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Create Investment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
  String _pin = '';

  void _handleConfirm() {
    setState(() => _pin = ''); // Reset PIN when opening modal
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return _buildPinModal(setModalState);
        },
      ),
    );
  }

  Widget _buildPinModal(StateSetter setModalState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black)),
              const Spacer(),
              Text('Enter Transaction Pin', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              const SizedBox(width: 24),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _pin.length > index ? Theme.of(context).primaryColor : (isDark ? Colors.white24 : Colors.black26),
                    width: _pin.length > index ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _pin.length > index
                      ? Container(width: 12, height: 12, decoration: BoxDecoration(color: isDark ? Colors.white : Colors.black, shape: BoxShape.circle))
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: () {}, child: Text('Forgot Pin?', style: TextStyle(color: Theme.of(context).primaryColor))),
          const SizedBox(height: 32),
          _buildKeypad(setModalState),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildKeypad(StateSetter setModalState) {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9']
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) => _buildKey(key, setModalState)).toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 60),
            _buildKey('0', setModalState),
            _buildKey('backspace', setModalState, isIcon: true),
          ],
        ),
      ],
    );
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _pickedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildKey(String val, StateSetter setModalState, {bool isIcon = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          if (val == 'backspace') {
            if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
          } else {
            if (_pin.length < 4) {
              _pin += val;
              if (_pin.length == 4) {
                Navigator.pop(context);
                _submitInvestment();
              }
            }
          }
        });
      },
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: isIcon ? Icon(Icons.backspace_outlined, color: isDark ? Colors.white : Colors.black) : Text(val, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _submitInvestment() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    
    // TODO: Upload _pickedFile to server and get the URL
    // For now, we are simulating this or using a placeholder if backend requires a real URL
    final documentUrl = 'https://valarpay.com/uploads/${_pickedFile!.name}'; 

    final request = CreateInvestmentRequest(
      amount: amount,
      currency: 'NGN',
      agreementReference: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      legalDocumentUrl: documentUrl,
    );

    final success = await ref.read(investmentActionNotifierProvider.notifier).createInvestment(request);
    
    if (success && mounted) {
      _showSuccessModal();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(investmentActionNotifierProvider).message ?? 'Failed to create investment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 60),
            const SizedBox(height: 20),
            Text('Investment Created Successfully', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Your funds have been debited and your investment is now active.', textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  context.go('/finance/investment/list');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
