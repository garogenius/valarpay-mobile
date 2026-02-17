import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/features/models/savings_models.dart';
import 'package:valarpay/features/notifiers/savings_notifier.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/features/auth/widgets/need_help_modal.dart';

class CreateSavingsPlanScreen extends ConsumerStatefulWidget {
  final String type; // FIXED or TARGET
  final String? initialTargetType;
  final String? initialAmount;

  const CreateSavingsPlanScreen({
    super.key, 
    required this.type,
    this.initialTargetType,
    this.initialAmount,
  });

  @override
  ConsumerState<CreateSavingsPlanScreen> createState() => _CreateSavingsPlanScreenState();
}

class _CreateSavingsPlanScreenState extends ConsumerState<CreateSavingsPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _dailyAmountController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  String? _targetType;
  String _frequency = 'Daily';
  String _preferredTime = '4:30am';
  String _fundVia = 'Valarpay';
  String? _duration;
  bool _strictMode = false;

  SavingsProduct? _product;

  @override
  void initState() {
    super.initState();
    
    // Pre-fill data if provided
    if (widget.initialTargetType != null) {
      _targetType = widget.initialTargetType;
      _nameController.text = widget.initialTargetType!;
    }
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!;
    }

    _amountController.addListener(_calculateDailyAmount);
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 90));
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(userNotifierProvider.notifier).refreshUserProfile();
      final notifier = ref.read(savingsProductNotifierProvider.notifier);
      await notifier.fetchProducts();
      final products = ref.read(savingsProductNotifierProvider).data ?? [];
      final typeStr = widget.type == 'FIXED' ? 'VALAR_AUTO_SAVE' : 'FLEX_SAVE';
      setState(() {
        _product = products.where((p) => p.name.contains(typeStr) || p.description.contains(typeStr)).firstOrNull ?? (products.isNotEmpty ? products.first : null);
      });
      
      // Trigger calculation if amount is pre-filled
      if (widget.initialAmount != null) {
        _calculateDailyAmount();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dailyAmountController.dispose();
    super.dispose();
  }

  void _calculateDailyAmount() {
    if (_amountController.text.isEmpty || _startDate == null || _endDate == null) {
      _dailyAmountController.text = '';
      return;
    }
    final target = double.tryParse(_amountController.text) ?? 0;
    final days = _endDate!.difference(_startDate!).inDays;
    if (days <= 0) {
      _dailyAmountController.text = '₦ 0';
      return;
    }
    final daily = target / days;
    _dailyAmountController.text = '₦ ${NumberFormat('#,###.##').format(daily)}';
  }

  void _showTargetTypePicker() {
    final types = [
      'Rent', 
      'Vacation', 
      'Business', 
      'School Fee', 
      'Enjoyment', 
      'Emergency Fund', 
      'Wedding', 
      'Gadget', 
      'Health', 
      'Travel', 
      'Birthday', 
      'Investment', 
      'Gift', 
      'Tax', 
      'Other'
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _buildSelectionModal('Select Target Type', types, _targetType, (val) {
        setState(() {
          _targetType = val;
          if (val != 'Other') {
            _nameController.text = val;
          } else {
            _nameController.clear();
          }
        });
      }),
    );
  }

  void _showDurationPicker() {
    final interestRate = _product?.interestRate ?? 0.17;
    final durations = [
      '3 Month @ ${(interestRate * 100).toInt()}%',
      '6 Months @ ${(interestRate * 100).toInt()}%',
      '1 Year @ ${(interestRate * 100).toInt()}%',
      '2 Years @ ${(interestRate * 100).toInt()}%',
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _buildSelectionModal('Select the duration', durations, _duration, (val) => setState(() => _duration = val)),
    );
  }

  void _showFrequencyPicker() {
    final frequencies = ['Daily', 'Weekly', 'Monthly'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _buildSelectionModal('Select Frequency', frequencies, _frequency, (val) => setState(() => _frequency = val)),
    );
  }

  void _showTimePicker() {
    final times = ['4:00am', '4:30am', '5:00am', '9:00am', '12:00pm', '1:00pm', '3:00pm'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _buildSelectionModal('Preferred Time', times, _preferredTime, (val) => setState(() => _preferredTime = val)),
    );
  }

  Widget _buildSelectionModal(String title, List<String> options, String? selected, Function(String) onSelect) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context), 
                  child: Icon(Icons.close, color: isDark ? Colors.white : Colors.black)
                ),
                const SizedBox(width: 16),
                Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: options.map((opt) => ListTile(
                onTap: () {
                  onSelect(opt);
                  Navigator.pop(context);
                },
                title: Text(
                  opt, 
                  style: TextStyle(
                    color: selected == opt ? const Color(0xFFF76301) : (isDark ? Colors.white70 : Colors.black87)
                  )
                ),
                trailing: Icon(
                  selected == opt ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected == opt ? const Color(0xFFF76301) : (isDark ? Colors.white24 : Colors.grey[400]),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now().add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark 
              ? const ColorScheme.dark(primary: Color(0xFFF76301), surface: Color(0xFF1F1F1F))
              : const ColorScheme.light(primary: Color(0xFFF76301), surface: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
        _calculateDailyAmount();
      });
    }
  }

  String _pin = '';

  void _showPinEntry() {
    setState(() => _pin = '');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
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
              GestureDetector(
                onTap: () => Navigator.pop(context), 
                child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black)
              ),
              const Spacer(),
              Text(
                'Enter Transaction Pin', 
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)
              ),
              const Spacer(),
              const SizedBox(width: 24),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _pin.length > index ? const Color(0xFFF76301) : (isDark ? Colors.white24 : Colors.grey[400]!),
                  width: _pin.length > index ? 2 : 1,
                ), 
                borderRadius: BorderRadius.circular(12)
              ),
              child: Center(
                child: _pin.length > index
                    ? Container(width: 12, height: 12, decoration: BoxDecoration(color: isDark ? Colors.white : Colors.black, shape: BoxShape.circle))
                    : null,
              ),
            )),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: () {}, child: const Text('Forgot Pin?', style: TextStyle(color: Color(0xFFF76301)))),
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
        for (var row in [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']])
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
                _finishCreate();
              }
            }
          }
        });
      },
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: isIcon 
          ? Icon(Icons.backspace_outlined, color: isDark ? Colors.white : Colors.black) 
          : Text(
              val, 
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)
            ),
      ),
    );
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.type == 'TARGET' && _targetType == null) return;
    if (widget.type == 'FIXED' && _duration == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (widget.type == 'FIXED') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 48),
              const SizedBox(height: 16),
              Text(
                'Confirm Deposit', 
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                )
              ),
              const SizedBox(height: 12),
              Text(
                'Your funds will be deducted from your account and securely locked according to your chosen schedule',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600], 
                  fontSize: 13, 
                  height: 1.5
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showPinEntry();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF76301),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Yes, I understand'),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      _finishCreate();
    }
  }

  Future<void> _finishCreate() async {
    final durationMonths = widget.type == 'FIXED' 
        ? (int.tryParse(_duration?.split(' ')[0] ?? '3') ?? 3)
        : (_endDate!.difference(_startDate!).inDays / 30).ceil().clamp(1, 120);

    final request = CreateSavingsPlanRequest(
      type: widget.type == 'FIXED' ? 'VALAR_AUTO_SAVE' : 'FLEX_SAVE',
      name: _nameController.text,
      description: 'Saving for ${_nameController.text}',
      goalAmount: double.parse(_amountController.text),
      durationMonths: durationMonths,
    );

    final success = await ref.read(savingsPlanNotifierProvider.notifier).createPlan(request);
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
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 48),
            const SizedBox(height: 24),
            _buildSummaryRow('Goal Name', _nameController.text),
            _buildSummaryRow('Deposit Amount', '₦${NumberFormat('#,###').format(double.tryParse(_amountController.text) ?? 0)}'),
            _buildSummaryRow('Interest Rate', '${((_product?.interestRate ?? 0.17) * 100).toInt()}%'),
            _buildSummaryRow('Lock Duration', widget.type == 'FIXED' ? (_duration ?? '3 Months') : '${(_endDate!.difference(_startDate!).inDays / 30).ceil()} Months'),
            _buildSummaryRow('Due Date', DateFormat('dd MMMM, yyyy').format(_endDate ?? DateTime.now())),
            _buildSummaryRow('Total Payable', '₦${NumberFormat('#,###').format((double.tryParse(_amountController.text) ?? 0) * (1 + (_product?.interestRate ?? 0.17)))}'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  if (widget.type == 'TARGET') {
                    context.go('/finance/savings/target/plans');
                  } else {
                    context.go('/finance/savings/fixed/plans');
                  }
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

  Widget _buildSummaryRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600], fontSize: 12)),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = ref.watch(savingsPlanNotifierProvider).isInitialLoading;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.type == 'FIXED' ? 'Create Goal' : 'Create Target',
          style: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.type == 'FIXED') ...[
                _buildTextField('Goal Name', _nameController, 'Enter the goal name'),
                const SizedBox(height: 20),
                _buildTextField('Deposit Amount', _amountController, '₦', keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                _buildSelectorField('Duration', _duration ?? 'Select the duration', _showDurationPicker),
              ] else ...[
                _buildSelectorField('Target Type', _targetType ?? 'Select a target', _showTargetTypePicker),
                if (_targetType == 'Other') ...[
                  const SizedBox(height: 20),
                  _buildTextField('Custom Goal Name', _nameController, 'Enter your goal name'),
                ],
                const SizedBox(height: 20),
                _buildTextField('Target Amount', _amountController, '₦', keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildDatePickerField('Start Date', _startDate, () => _selectDate(context, true))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDatePickerField('End Date', _endDate, () => _selectDate(context, false))),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField('Est. Daily Saving (Informational)', _dailyAmountController, '', readOnly: true),
              ],
              const SizedBox(height: 32),
              Text('Fund Account', style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700], fontSize: 13)),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final wallet = ref.watch(userNotifierProvider).data?.firstOrNull?.wallets.firstOrNull;
                  return _buildFundViaOption('Valarpay', wallet?.accountNumber ?? '0000000000');
                },
              ),
              if (widget.type == 'TARGET') ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Enable Strict Saving Mode', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                          Text('Lock up your funds. You won\'t be able to cancel or withdraw early.', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600], fontSize: 10)),
                        ],
                      ),
                    ),
                    Switch(value: _strictMode, onChanged: (v) => setState(() => _strictMode = v), activeColor: const Color(0xFFF76301)),
                  ],
                ),
              ],
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF76301),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorField(String label, String value, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = !value.toLowerCase().contains('select');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700], fontSize: 13)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.grey[100], 
              borderRadius: BorderRadius.circular(12)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value, 
                  style: TextStyle(
                    color: isSelected ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white24 : Colors.grey[400]), 
                    fontSize: 15
                  )
                ),
                Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white54 : Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text, bool readOnly = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700], fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint.length > 2 ? hint : null,
            hintStyle: TextStyle(color: isDark ? Colors.white12 : Colors.grey[400]),
            prefixText: hint.length <= 2 ? '$hint ' : null,
            prefixStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
            filled: true,
            fillColor: isDark ? const Color(0xFF1F1F1F) : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDatePickerField(String label, DateTime? date, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700], fontSize: 13)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : Colors.grey[100], 
              borderRadius: BorderRadius.circular(12)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Select', 
                  style: TextStyle(
                    color: date != null ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white24 : Colors.grey[400]), 
                    fontSize: 14
                  )
                ),
                Icon(Icons.calendar_today, color: isDark ? Colors.white54 : Colors.grey[600], size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFundViaOption(String name, String number) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isSelected = _fundVia == name;
    return InkWell(
      onTap: () => setState(() => _fundVia = name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F1F1F) : Colors.grey[100], 
          borderRadius: BorderRadius.circular(12)
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.wallet, color: Color(0xFFF76301)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name, 
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black, 
                      fontSize: 14, fontWeight: FontWeight.bold
                    )
                  ),
                  Text(
                    '$number Account', 
                    style: TextStyle(
                      color: isDark ? Colors.white24 : Colors.grey[600], 
                      fontSize: 11
                    )
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off, 
              color: isSelected ? const Color(0xFFF76301) : (isDark ? Colors.white24 : Colors.grey[400])
            ),
          ],
        ),
      ),
    );
  }
}
