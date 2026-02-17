import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/models/vcard_models.dart';
import 'package:valarpay/features/notifiers/vcard_notifier.dart';

class FundVCardScreen extends ConsumerStatefulWidget {
  final String cardId;
  const FundVCardScreen({super.key, required this.cardId});

  @override
  ConsumerState<FundVCardScreen> createState() => _FundVCardScreenState();
}

class _FundVCardScreenState extends ConsumerState<FundVCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Fund Card', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Move funds from your USD wallet to your virtual card.',
                style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 32),
              _buildLabel('Amount to Fund', isDark),
              _buildTextField(
                _amountController, 
                '0.00', 
                Icons.attach_money, 
                isDark,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 24),
              _buildLabel('Wallet Pin', isDark),
              _buildTextField(
                _pinController, 
                '****', 
                Icons.lock_outline, 
                isDark,
                obscureText: true, 
                keyboardType: TextInputType.number, 
                maxLength: 4,
              ),
              const SizedBox(height: 48),
              FullWidthButton(
                text: _isSubmitting ? 'Processing...' : 'Confirm Funding',
                onPressed: _isSubmitting ? null : _handleFund,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isDark, {bool obscureText = false, TextInputType? keyboardType, int? maxLength}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: isDark ? Colors.white24 : Colors.grey, size: 20),
        filled: true,
        fillColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
        ),
        counterText: '',
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'This field is required';
        return null;
      },
    );
  }

  Future<void> _handleFund() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    
    final request = FundCardRequest(
      cardId: widget.cardId,
      amount: double.parse(_amountController.text),
      walletPin: _pinController.text,
    );

    final success = await ref.read(cardNotifierProvider.notifier).fundCard(request);
    
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card funded successfully')));
      } else {
        final error = ref.read(cardNotifierProvider).error ?? 'Failed to fund card';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }
}
