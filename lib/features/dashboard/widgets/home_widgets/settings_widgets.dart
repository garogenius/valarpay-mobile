import 'package:flutter/material.dart';
import 'package:valarpay/core/themes/color_utils.dart';

class SettingsListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const SettingsListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: appTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: appTheme.primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle:
            subtitle != null
                ? Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                )
                : null,
        trailing:
            trailing ??
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class SettingsToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggleTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: appTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: appTheme.primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle:
            subtitle != null
                ? Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                )
                : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: appTheme.primaryColor,
        ),
      ),
    );
  }
}

class SecurityQuestionDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final ValueChanged<String>? onAnswerChanged;

  const SecurityQuestionDropdown({
    super.key,
    required this.label,
    this.value,
    required this.options,
    required this.onChanged,
    this.onAnswerChanged,
  });

  @override
  State<SecurityQuestionDropdown> createState() =>
      _SecurityQuestionDropdownState();
}

class _SecurityQuestionDropdownState extends State<SecurityQuestionDropdown> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.grey[400] : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.value,
              hint: Text(
                'Select a question',
                style: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.black,
                ),
              ),
              isExpanded: true,
              onChanged: widget.onChanged,
              items:
                  widget.options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color:
                widget.value != null
                    ? Theme.of(context).cardColor
                    : Theme.of(context).cardColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: TextField(
            controller: _answerController,
            enabled: widget.value != null,
            onChanged: widget.onAnswerChanged,
            decoration: InputDecoration(
              hintText:
                  widget.value != null
                      ? 'Your Answer'
                      : 'Select a question first',
              hintStyle: TextStyle(
                color:
                    isDark
                        ? (widget.value != null
                            ? Colors.grey[600]
                            : Colors.grey[400])
                        : Colors.black,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class CloseAccountDialog extends StatelessWidget {
  const CloseAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      title: const Text('Close Account?', style: TextStyle(color: Colors.red)),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('By closing your account, you will:'),
          SizedBox(height: 8),
          Text('• Lose access to your wallet balance'),
          Text('• Not be able to receive or send money'),
          Text('• Lose access to all transaction history'),
          Text('• Not be able to use all of ValarPay services'),
          Text('• Lose access to bill payments and services'),
          Text('• Lose all rewards and cashback'),
          Text('• Be unable to reopen this account later'),
          SizedBox(height: 8),
          Text('Are you sure you want to continue?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _showHelpUsImproveDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  void _showHelpUsImproveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HelpUsImproveDialog(),
    );
  }
}

class HelpUsImproveDialog extends StatefulWidget {
  const HelpUsImproveDialog({super.key});

  @override
  State<HelpUsImproveDialog> createState() => _HelpUsImproveDialogState();
}

class _HelpUsImproveDialogState extends State<HelpUsImproveDialog> {
  String? selectedReason;
  final List<String> reasons = [
    'I no longer use this service',
    'I found a better alternative',
    'I have a security or trust concerns',
    'Poor customer support experience',
    'App is too slow/buggy',
    'Others',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      title: const Text('Help Us Improve'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Help us improve our service by telling us why you\'re leaving',
          ),
          const SizedBox(height: 16),
          const Text('Select a Reason'),
          const SizedBox(height: 12),
          ...reasons.map(
            (reason) => GestureDetector(
              onTap: () {
                setState(() {
                  selectedReason = reason;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              selectedReason == reason
                                  ? appTheme.primaryColor
                                  : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child:
                          selectedReason == reason
                              ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: appTheme.primaryColor,
                                  ),
                                ),
                              )
                              : null,
                    ),
                    Expanded(child: Text(reason)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              selectedReason != null
                  ? () {
                    Navigator.of(context).pop();
                    _showTransactionPinDialog(context);
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: appTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  void _showTransactionPinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TransactionPinDialog(),
    );
  }
}

class TransactionPinDialog extends StatefulWidget {
  const TransactionPinDialog({super.key});

  @override
  State<TransactionPinDialog> createState() => _TransactionPinDialogState();
}

class _TransactionPinDialogState extends State<TransactionPinDialog> {
  String pin = '';
  final int pinLength = 4;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Expanded(
                  child: Text(
                    'Enter Transaction Pin',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pinLength, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      index < pin.length ? '•' : '',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              children: [
                ...List.generate(9, (index) {
                  return _buildNumberButton('${index + 1}');
                }),
                const SizedBox(),
                _buildNumberButton('0'),
                _buildNumberButton('⌫', isDelete: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String text, {bool isDelete = false}) {
    return GestureDetector(
      onTap: () {
        if (isDelete) {
          if (pin.isNotEmpty) {
            setState(() {
              pin = pin.substring(0, pin.length - 1);
            });
          }
        } else {
          if (pin.length < pinLength) {
            setState(() {
              pin += text;
            });
            if (pin.length == pinLength) {
              _verifyPin();
            }
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  void _verifyPin() {
    // Simulate PIN verification
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
        _showConfirmationDialog(context);
      }
    });
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: const Text('Are You Sure?'),
            content: const Text(
              'Deleting your account will permanently remove all your data. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showAccountDeletedDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Yes, Continue'),
              ),
            ],
          ),
    );
  }

  void _showAccountDeletedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Account Deleted',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your account has been successfully deleted. Thank you for using our service.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to login or onboarding
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme.primaryColor,
                      foregroundColor: Colors.white,
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

class QuestionSelectionBottomSheet extends StatefulWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String> onSelected;

  const QuestionSelectionBottomSheet({
    super.key,
    required this.options,
    this.selectedOption,
    required this.onSelected,
  });

  @override
  State<QuestionSelectionBottomSheet> createState() =>
      _QuestionSelectionBottomSheetState();
}

class _QuestionSelectionBottomSheetState
    extends State<QuestionSelectionBottomSheet> {
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Expanded(
                  child: Text(
                    'Select Question',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.options.length,
              itemBuilder: (context, index) {
                final option = widget.options[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOption = option;
                    });
                    widget.onSelected(option);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  selectedOption == option
                                      ? appTheme.primaryColor
                                      : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child:
                              selectedOption == option
                                  ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: appTheme.primaryColor,
                                      ),
                                    ),
                                  )
                                  : null,
                        ),
                        Expanded(child: Text(option)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
