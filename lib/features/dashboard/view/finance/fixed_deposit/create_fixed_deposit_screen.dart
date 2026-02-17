import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/features/models/fixed_deposit_models.dart';
import 'package:valarpay/features/notifiers/fixed_deposit_notifier.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/features/auth/widgets/need_help_modal.dart';
import 'package:valarpay/features/models/wallet.dart';
import 'package:valarpay/core/utils/app_messenger.dart';

class CreateFixedDepositScreen extends ConsumerStatefulWidget {
  final String? initialAmount;

  const CreateFixedDepositScreen({super.key, this.initialAmount});

  @override
  ConsumerState<CreateFixedDepositScreen> createState() => _CreateFixedDepositScreenState();
}

class _CreateFixedDepositScreenState extends ConsumerState<CreateFixedDepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  FixedDepositPlan? _selectedPlan;
  String _rolloverType = 'NONE';
  String? _selectedWalletId;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fixedDepositPlanNotifierProvider.notifier).fetchPlans();
      ref.read(userNotifierProvider.notifier).refreshUserProfile();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _pin = '';

  void _handleConfirm() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedPlan == null) {
      AppMessenger.show(context, message: 'Please select a fixed deposit plan', type: MessageType.warning);
      return;
    }
    
    setState(() => _pin = '');
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
                    color: _pin.length > index ? const Color(0xFFF76301) : (isDark ? Colors.white24 : Colors.black26),
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
          TextButton(onPressed: () {}, child: Text('Forgot Pin?', style: TextStyle(color: const Color(0xFFF76301)))),
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
                _submitDeposit();
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

  Future<void> _submitDeposit() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final request = CreateFixedDepositRequest(
      planId: _selectedPlan!.id,
      amount: double.parse(amountText),
      rolloverType: _rolloverType,
    );

    final success = await ref.read(fixedDepositNotifierProvider.notifier).createDeposit(request);
    if (success && mounted) {
      _showSuccessModal();
    } else if (mounted) {
      final errorState = ref.read(fixedDepositNotifierProvider);
      AppMessenger.show(
        context,
        message: errorState.message ?? 'Failed to create fixed deposit',
        type: MessageType.error,
      );
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
            Text('Fixed Deposit Created', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Your funds are now growing with us.', textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  context.go('/finance/fixed-deposit/plans');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF76301),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
    final planState = ref.watch(fixedDepositPlanNotifierProvider);
    final depositState = ref.watch(fixedDepositNotifierProvider);
    final userState = ref.watch(userNotifierProvider);
    final wallets = userState.data?.firstOrNull?.wallets ?? [];
    final isLoading = planState.isInitialLoading || depositState.isInitialLoading;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        title: Text('New Fixed Deposit', style: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
      body: planState.isInitialLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF76301)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Select Fixed Deposit Plan', isDark),
                    const SizedBox(height: 8),
                    _buildDropdown<FixedDepositPlan>(
                      value: _selectedPlan,
                      hint: 'Choose a plan',
                      items: (planState.data ?? []).map((plan) {
                        return DropdownMenuItem(
                          value: plan,
                          child: Text('${plan.name} (${(plan.interestRate * 100).toInt()}% p.a)', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedPlan = val),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField('Fixed Deposit Amount', _amountController, '₦', isDark, keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    _buildLabel('Funding Account', isDark),
                    const SizedBox(height: 12),
                    _buildWalletOption(wallets.firstOrNull, isDark),
                    const SizedBox(height: 20),
                    _buildLabel('Rollover Option', isDark),
                    const SizedBox(height: 8),
                    _buildDropdown<String>(
                      value: _rolloverType,
                      items: const [
                        DropdownMenuItem(value: 'NONE', child: Text('No Rollover')),
                        DropdownMenuItem(value: 'PRINCIPAL', child: Text('Rollover Principal Only')),
                        DropdownMenuItem(value: 'PRINCIPAL_AND_INTEREST', child: Text('Rollover Principal + Interest')),
                      ],
                      onChanged: (val) => setState(() => _rolloverType = val!),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF76301),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Create Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(text, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13));
  }

  Widget _buildDropdown<T>({required T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged, String? hint, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1F1F1F) : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
          hint: hint != null ? Text(hint, style: TextStyle(color: isDark ? Colors.white24 : Colors.black26)) : null,
          isExpanded: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, bool isDark, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isDark),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white12 : Colors.black12),
            filled: true,
            fillColor: isDark ? const Color(0xFF1F1F1F) : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildWalletOption(WalletModel? wallet, bool isDark) {
    final name = 'Valarpay Account';
    final balance = wallet?.balance ?? 0.0;
    final isSelected = _selectedWalletId == (wallet?.id ?? 'default') || (_selectedWalletId == null && wallet != null);

    return InkWell(
      onTap: () => setState(() => _selectedWalletId = wallet?.id ?? 'default'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F1F1F) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: const Color(0xFFF76301)) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(color: const Color(0xFFF76301).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('₦${NumberFormat('#,##0.00').format(balance)}', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFFF76301) : (isDark ? Colors.white10 : Colors.black12),
            ),
          ],
        ),
      ),
    );
  }
}
