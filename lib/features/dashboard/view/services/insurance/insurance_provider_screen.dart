import 'package:flutter/material.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import '../../../widgets/services_widgets/insurance_widgets/service_plan_modal.dart';
import '../../../widgets/services_widgets/insurance_widgets/service_duration_modal.dart';

class InsuranceProviderScreen extends StatefulWidget {
  final String providerName;

  const InsuranceProviderScreen({
    super.key,
    required this.providerName,
  });

  @override
  State<InsuranceProviderScreen> createState() =>
      _InsuranceProviderScreenState();
}

class _InsuranceProviderScreenState extends State<InsuranceProviderScreen> {
  final TextEditingController policyNumberController = TextEditingController();
  String selectedPlan = 'Universal plan';
  String selectedDuration = '1 year';
  final TextEditingController amountController = TextEditingController();
  int serviceFee = 500;
  bool saveBeneficiary = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.providerName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Policy Number
            Text(
              'Policy Number',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ReuseableTextFieldWithCountry(
                controller: policyNumberController,
                hintText: 'PB236',
                isReadOnly: false,
                textInputType: TextInputType.text,
                showCountryLabel: false),

            const SizedBox(height: 24),

            // Service Plan
            Text(
              'Service Plan',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showServicePlanModal(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedPlan,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Duration
            Text(
              'Duration',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showServiceDurationModal(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDuration,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Amount
            Text(
              'Amount',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ReuseableAmountTextfield(
                amountController: amountController,
                prefixText: '₦',
                hintText: '5,000'),

            const SizedBox(height: 60),

            // Continue Button

            FullWidthButton(
                text: 'Continue',
                onPressed: () {
                  if (policyNumberController.text.isNotEmpty &&
                      amountController.text.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ReuseableTransactionDetailsScreen(
                                totalAmount: double.parse(amountController.text),
                                saveBeneficiary: saveBeneficiary,
                                onSaveBeneficiaryChanged: (value) {
                                  setState(() {
                                    saveBeneficiary = value;
                                  });
                                },
                                hasBottom: false,
                          topTitleText: 'Transaction',
                                topTransactionsDetailsList: [
                                  buildDetailRow('Policy Number',
                                      policyNumberController.text, isDark),
                                  buildDetailRow('Plan', selectedPlan, isDark),
                                  buildDetailRow(
                                      'Duration', selectedDuration, isDark),
                                  buildDetailRow('Amount',
                                      '₦${amountController.text}', isDark),
                                  buildDetailRow(
                                      'Fee', '₦${serviceFee}', isDark),
                                  const Divider(),
                                  buildDetailRow(
                                      'Total Amount',
                                      '₦${(int.parse(amountController.text) + serviceFee)}',
                                      isDark,
                                      isTotal: true)
                                ],
                                onButtonPressed: () async {
                                  final pin =
                                      await BiometricTransactionPinModal.show(context);
                                  if (pin != null &&
                                      pin.length == 4 &&
                                      mounted) {
                                    if (mounted) Navigator.pop(context);
                                    if (mounted) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TransactionReceiptWidget(
                                                    headerText: 'Transaction',
                                                    amount:
                                                        '${(int.parse(amountController.text) + serviceFee)}',
                                                    topDetails: [
                                                      TransactionDetail(
                                                          label: 'Plan',
                                                          value: selectedPlan),
                                                      TransactionDetail(
                                                          label: 'Duration',
                                                          value:
                                                              selectedDuration),
                                                      TransactionDetail(
                                                          label: 'Amount',
                                                          value:
                                                              '₦${amountController.text}'),
                                                      TransactionDetail(
                                                          label: 'Fee',
                                                          value:
                                                              '₦${serviceFee}'),
                                                      TransactionDetail(
                                                          label:
                                                              'Amount Debited',
                                                          value:
                                                              '₦${(int.parse(amountController.text) + serviceFee)}'),
                                                    ],
                                                    bottomDetails: [
                                                      TransactionDetail(
                                                          label:
                                                              'Transaction ID',
                                                          value:
                                                              'TXN${DateTime.now().millisecondsSinceEpoch}',
                                                          showCopyIcon: true),
                                                      TransactionDetail(
                                                          label:
                                                              'Policy Number',
                                                          value:
                                                              policyNumberController
                                                                  .text),
                                                      TransactionDetail(
                                                          label:
                                                              'Payment Source',
                                                          value:
                                                              'ValarPay Account'),
                                                      TransactionDetail(
                                                          label: 'Date & Time',
                                                          value:
                                                              '29 Sep 2025 | 8:15 pm')
                                                    ],
                                                  )));
                                    }
                                  }
                                },
                              )),
                    );
                  }
                })
          ],
        ),
      ),
    );
  }

  void _showServicePlanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ServicePlanModal(
        selectedPlan: selectedPlan,
        onPlanSelected: (plan) {
          setState(() {
            selectedPlan = plan;
          });
        },
      ),
    );
  }

  void _showServiceDurationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceDurationModal(
        selectedDuration: selectedDuration,
        onDurationSelected: (duration) {
          setState(() {
            selectedDuration = duration;
          });
        },
      ),
    );
  }
}
