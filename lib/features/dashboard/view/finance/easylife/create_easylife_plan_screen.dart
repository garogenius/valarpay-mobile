import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/features/models/easylife_models.dart';
import 'package:valarpay/features/notifiers/easylife_notifier.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CreateEasyLifePlanScreen extends ConsumerStatefulWidget {
  final String? initialName;
  final String? initialAmount;

  const CreateEasyLifePlanScreen({super.key, this.initialName, this.initialAmount});

  @override
  ConsumerState<CreateEasyLifePlanScreen> createState() => _CreateEasyLifePlanScreenState();
}

class _CreateEasyLifePlanScreenState extends ConsumerState<CreateEasyLifePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _durationController = TextEditingController(text: '90');
  String _frequency = 'DAILY';
  bool _autoDebit = true;
  EasyLifeProduct? _product;

  @override
  void initState() {
    super.initState();
    
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(userNotifierProvider.notifier).refreshUserProfile();
      await ref.read(easyLifeProductNotifierProvider.notifier).fetchProductInfo();
      final product = ref.read(easyLifeProductNotifierProvider).data?.firstOrNull;
      if (product != null) {
        setState(() {
          _product = product;
          if (product.contributionFrequencies.isNotEmpty) {
            _frequency = product.contributionFrequencies.first;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _showFrequencyPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text('Select Frequency', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...(_product?.contributionFrequencies ?? ['DAILY', 'WEEKLY', 'MONTHLY']).map((opt) => _buildFrequencyOption(opt)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyOption(String option) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isSelected = _frequency == option;
    return ListTile(
      onTap: () {
        setState(() => _frequency = option);
        Navigator.pop(context);
      },
      title: Text(option, style: TextStyle(color: isSelected ? const Color(0xFFF76301) : (isDark ? Colors.white70 : Colors.black87))),
      trailing: isSelected ? const Icon(Icons.radio_button_checked, color: Color(0xFFF76301)) : Icon(Icons.radio_button_off, color: isDark ? Colors.white24 : Colors.black12),
    );
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    final request = CreateEasyLifePlanRequest(
      name: _nameController.text,
      description: 'EasyLife Savings for ${_nameController.text}',
      goalAmount: double.parse(_amountController.text.replaceAll(',', '')),
      durationDays: int.parse(_durationController.text),
      contributionFrequency: _frequency,
      autoDebitEnabled: _autoDebit,
    );

    final success = await ref.read(easyLifePlanNotifierProvider.notifier).createPlan(request);
    if (success && mounted) {
      _showSuccessModal();
    }
  }

  void _showSuccessModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 60),
            const SizedBox(height: 20),
            Text('EasyLife Plan Created', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Your automated savings plan is now active.', textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  context.go('/finance/easylife/intro');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF76301),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = ref.watch(easyLifePlanNotifierProvider).isInitialLoading;
    final userState = ref.watch(userNotifierProvider);
    final walletBalance = userState.data?.firstOrNull?.wallets.firstOrNull?.balance ?? 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        title: const Text('Setup EasyLife Plan', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Plan Name', _nameController, 'e.g. Vacation Fund'),
              const SizedBox(height: 20),
              _buildTextField('Goal Amount', _amountController, '₦', keyboardType: TextInputType.number, inputFormatters: [CurrencyInputFormatter()]),
              const SizedBox(height: 20),
              _buildTextField('Duration (Days)', _durationController, '90', keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              Text('Contribution Frequency', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showFrequencyPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F1F1F) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_frequency, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15)),
                      Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.black54),
                    ],
                  ),
                ),
              ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Enable Auto-Debit', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15)),
                  Switch(
                    value: _autoDebit,
                    onChanged: (val) => setState(() => _autoDebit = val),
                    activeColor: const Color(0xFFF76301),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF76301),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Create Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.2)),
            filled: true,
            fillColor: isDark ? const Color(0xFF1F1F1F) : Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}
