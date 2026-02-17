import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/models/vcard_models.dart';
import 'package:valarpay/features/notifiers/vcard_notifier.dart';
import 'package:valarpay/features/dashboard/view/cards/widgets/virtual_card_widget.dart';
import 'package:go_router/go_router.dart';

class CreateVCardScreen extends ConsumerStatefulWidget {
  const CreateVCardScreen({super.key});

  @override
  ConsumerState<CreateVCardScreen> createState() => _CreateVCardScreenState();
}

class _CreateVCardScreenState extends ConsumerState<CreateVCardScreen> {
  bool _showForm = false;
  final _formKey = GlobalKey<FormState>();
  String _selectedCurrency = 'USD';
  final _labelController = TextEditingController();
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showForm) {
      return _buildFormScreen();
    }
    return _buildIntroScreen();
  }

  Widget _buildIntroScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Get Virtual Card', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VirtualCardWidget(),
            const SizedBox(height: 32),
            Text('Payment Details', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200),
              ),
              child: Column(
                children: [
                   _buildPaymentRow('Issuance Fee', '\$2.00', isDark),
                  const SizedBox(height: 16),
                  _buildPaymentRow('VAT Fee', '\$0.00', isDark),
                  const SizedBox(height: 16),
                  Divider(color: isDark ? Colors.white10 : Colors.grey.shade200),
                  const SizedBox(height: 16),
                  _buildPaymentRow('Total Fee', '\$2.00', isDark, isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 48),
            FullWidthButton(
              text: 'Continue',
              onPressed: () => setState(() => _showForm = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormScreen() {
     final isDark = Theme.of(context).brightness == Brightness.dark;
     return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Card Configuration', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _showForm = false)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Select Currency', isDark),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade300),
                ),
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                  items: ['USD'].map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedCurrency = val!),
                ),
              ),
              const SizedBox(height: 24),
              _buildLabel('Card Label', isDark),
              _buildTextField(_labelController, 'e.g. My Shopping Card', Icons.label_outline, isDark),
              const SizedBox(height: 24),
              _buildLabel('Initial Funding Amount', isDark),
              _buildTextField(_amountController, '0.00', Icons.attach_money, isDark, keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              _buildLabel('Set Card PIN (8 Digits)', isDark),
              _buildTextField(_pinController, '********', Icons.lock_outline, isDark, obscureText: true, keyboardType: TextInputType.number, maxLength: 8),
              const SizedBox(height: 48),
              FullWidthButton(
                text: _isSubmitting ? 'Creating Card...' : 'Create Card',
                onPressed: _isSubmitting ? null : _handleCreate,
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
        if (maxLength != null && val.length != maxLength) return 'Must be $maxLength digits';
        return null;
      },
    );
  }

  Widget _buildPaymentRow(String label, String value, bool isDark, {bool isTotal = false}) {
     return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600, fontSize: 13)),
        Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    
    final request = CreateCardRequest(
      currency: _selectedCurrency,
      label: _labelController.text,
      fundingAmount: double.parse(_amountController.text),
      pin: _pinController.text,
    );

    final success = await ref.read(cardNotifierProvider.notifier).createCard(request);
    
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Virtual card created successfully')));
      } else {
        final error = ref.read(cardNotifierProvider).error ?? 'Failed to create card';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }
}
