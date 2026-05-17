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
  bool _isSubmitting = false;
  
  final List<String> _designs = [
    'Midnight Executive',
    'Quantum Grid',
    'Titanium Edge',
    'Ethereal Flow',
    'Solar Velocity',
    'Prism Digital'
  ];
  String _selectedDesign = 'Midnight Executive';
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    _pageController.dispose();
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
        title: const Text('Create Virtual Card', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Design', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                  Text('${_designs.length} DESIGNS AVAILABLE', style: const TextStyle(color: Color(0xFFF76301), fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(
              height: 250,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _selectedDesign = _designs[index]),
                itemCount: _designs.length,
                itemBuilder: (context, index) {
                  final isSelected = _designs[index] == _selectedDesign;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    transform: Matrix4.identity()..scale(isSelected ? 1.0 : 0.95),
                    child: Opacity(
                      opacity: isSelected ? 1.0 : 0.5,
                      child: Column(
                        children: [
                          VirtualCardWidget(designTheme: _designs[index]),
                          const SizedBox(height: 12),
                          if (isSelected)
                            Text(_designs[index], style: const TextStyle(color: Color(0xFFF76301), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
             Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card Benefits', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildBenefitRow(Icons.public, 'Global Online Acceptance', 'Valid on Netflix, Amazon, Google, Facebook Ads & more.', isDark),
                        const SizedBox(height: 16),
                        _buildBenefitRow(Icons.security, 'Advanced Security Protection', 'Fully compatible with 3D Secure verification.', isDark),
                        const SizedBox(height: 16),
                        _buildBenefitRow(Icons.bolt, 'Instant Activation & Funding', 'Issued instantly. Top up directly from your Valarpay wallet.', isDark),
                        const SizedBox(height: 16),
                        _buildBenefitRow(Icons.money_off, 'No Hidden Fees', '\$0 monthly maintenance or transaction setup charges.', isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  FullWidthButton(
                    text: 'Continue',
                    onPressed: () => setState(() => _showForm = true),
                  ),
                ],
              ),
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
              _buildLabel('Card Title', isDark),
              _buildTextField(_labelController, 'My Valarpay Virtual Card', Icons.label_outline, isDark),
              const SizedBox(height: 24),
              _buildLabel('Funding Amount', isDark),
              _buildTextField(_amountController, '100.00', Icons.attach_money, isDark, keyboardType: TextInputType.number),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFF76301), Color(0xFF7C2E00)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: const Color(0xFFF76301).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isSubmitting ? null : _handleCreate,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_isSubmitting ? 'ISSUING...' : 'ISSUE VIRTUAL CARD', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      if (!_isSubmitting) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.bolt, color: Colors.white),
                      ],
                    ],
                  ),
                ),
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
      child: Text(text, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isDark, {bool obscureText = false, TextInputType? keyboardType, int? maxLength}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.grey, fontSize: 16),
        prefixIcon: Icon(icon, color: const Color(0xFFF76301), size: 24),
        filled: true,
        fillColor: isDark ? const Color(0xFF0D1D2A) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: isDark ? const BorderSide(color: Colors.white10) : BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: isDark ? const BorderSide(color: Colors.white10) : BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: const BorderSide(color: Color(0xFFF76301)),
        ),
        counterText: '',
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'This field is required';
        return null;
      },
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String subtitle, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF76301).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFF76301), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark ? Colors.white30 : Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
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
      color: _selectedDesign,
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
