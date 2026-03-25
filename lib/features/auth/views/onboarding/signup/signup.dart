import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/models/signup_request.dart';
import '../../../../../features/auth/widgets/need_help_modal.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  String selectedAccountType = 'Personal';
  String selectedCurrency = 'NGN';

  void _showDialog<T>({
    required String title,
    required List<DialogOption<T>> options,
  }) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            backgroundColor: Theme.of(ctx).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(
                          Icons.arrow_back,
                          color: Theme.of(ctx).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(ctx).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: options.map(
                          (option) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildDialogOption(option, ctx),
                          ),
                        ).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDialogOption<T>(DialogOption<T> option, BuildContext ctx) {
    final isSelected = option.isSelected;
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        if (option.disabled == false) {
          option.onTap();
          Navigator.pop(ctx);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: option.disabled == true
              ? (isDark ? Colors.white10 : Colors.grey.shade100)
              : Colors.transparent,
          border: Border.all(
            width: 1,
            color: isSelected
                ? (option.activeColor ?? Theme.of(ctx).primaryColor)
                : (isDark ? Colors.white12 : Colors.grey.shade300),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (option.flag != null)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (option.activeColor?.withOpacity(0.2) ??
                          Theme.of(ctx).primaryColor.withOpacity(0.2))
                      : (isDark ? Colors.white10 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(option.flag!, style: const TextStyle(fontSize: 18)),
              ),
            if (option.flag != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(ctx).colorScheme.onSurface,
                    ),
                  ),
                  if (option.subtitle != null) const SizedBox(height: 6),
                  if (option.subtitle != null)
                    Text(
                      option.subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(ctx)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ),
            Radio<T>(
              value: option.value,
              groupValue: option.groupValue,
              onChanged: (_) {
                if (option.disabled == false) {
                  option.onTap();
                }
              },
              activeColor: option.activeColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountTypeDialog() {
    _showDialog<String>(
      title: 'Choose Account',
      options: [
        DialogOption(
          title: 'Personal',
          subtitle: 'For individuals and everyday needs',
          value: 'Personal',
          groupValue: selectedAccountType,
          activeColor: Theme.of(context).primaryColor,
          onTap: () => {setState(() => selectedAccountType = 'Personal')},
        ),
        DialogOption(
          title: 'Business',
          subtitle: 'For organizations and corporate needs',
          value: 'Business',
          groupValue: selectedAccountType,
          activeColor: Theme.of(context).primaryColor,
          onTap: () => setState(() => selectedAccountType = 'Business'),
        ),
      ],
    );
  }

  void _showCurrencyDialog() {
    _showDialog<String>(
      title: 'Choose Currency',
      options: [
        DialogOption(
          title: 'NGN',
          subtitle: 'For transactions in Naira',
          flag: '🇳🇬',
          value: 'NGN',
          groupValue: selectedCurrency,
          activeColor: Colors.green,
          onTap: () => setState(() => selectedCurrency = 'NGN'),
        ),
        DialogOption(
          title: 'USD',
          subtitle: 'For transactions in US Dollars',
          flag: '🇺🇸',
          value: 'USD',
          groupValue: selectedCurrency,
          activeColor: Colors.grey,
          disabled: true,
          onTap: () => {},
        ),
        DialogOption(
          title: 'GBP',
          subtitle: 'For transactions in Pounds',
          flag: '🇬🇧',
          value: 'GBP',
          groupValue: selectedCurrency,
          activeColor: Colors.grey,
          disabled: true,
          onTap: () => {},
        ),
        DialogOption(
          title: 'EUR',
          subtitle: 'For transactions in Euros',
          flag: '🇪🇺',
          value: 'EUR',
          groupValue: selectedCurrency,
          activeColor: Colors.grey,
          disabled: true,
          onTap: () => {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => NeedHelpModal.show(context),
            child: Text(
              'Need Help?',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogoHeader(),
            const SizedBox(height: 40),
            Text(
              'Create account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              'Select the account type that best fits your needs',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Label + selection tile
            Text(
              'Account Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            _buildSelectionTile(
              selectedAccountType,
              _showAccountTypeDialog,
              Icons.account_balance_wallet,
            ),
            const SizedBox(height: 24),

            Text(
              'Currency',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            _buildSelectionTile(
              selectedCurrency,
              _showCurrencyDialog,
              Icons.currency_exchange_sharp,
            ),
            const SizedBox(height: 50),

            FullWidthButton(
              text: 'Continue',
              onPressed: () {
                SignUpRequest request = SignUpRequest(
                  accountType: selectedAccountType.toUpperCase(),
                  countryCode: selectedCurrency,
                );

                if (selectedAccountType == 'Personal') {
                  context.push('/personal-details', extra: request);
                } else {
                  context.push('/business-details', extra: request);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: ClipRRect(
            // Use ClipRRect to apply border radius to the image
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo2.png',
              fit: BoxFit.cover, // Cover the container area
              width: 40,
              height: 40,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Valarpay',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionTile(String value, VoidCallback onTap, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.5),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

class DialogOption<T> {
  final String title;
  final String? subtitle;
  final String? flag;
  final T value;
  final T? groupValue;
  final Color? activeColor;
  final bool isSelected;
  final VoidCallback onTap;
  bool disabled;

  DialogOption({
    required this.title,
    this.subtitle,
    this.flag,
    required this.value,
    this.groupValue,
    this.activeColor,
    required this.onTap,
    this.disabled = false,
  }) : isSelected = value == groupValue;
}
