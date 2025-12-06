import 'package:flutter/material.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_amount_textfield.dart';
import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import '../../../widgets/services_widgets/education_widgets/service_type_modal.dart';

class InstitutionPaymentScreen extends StatefulWidget {
  final String institutionName;

  const InstitutionPaymentScreen({super.key, required this.institutionName});

  @override
  State<InstitutionPaymentScreen> createState() =>
      _InstitutionPaymentScreenState();
}

class _InstitutionPaymentScreenState extends State<InstitutionPaymentScreen> {
  final TextEditingController institutionNumberController =
      TextEditingController();
  String selectedServiceType = 'Exam Fee';
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  int serviceFee = 500;
  bool saveBeneficiary = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.institutionName,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
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
            // Institution Name
            Text(
              'Institution Name',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ReuseableTextFieldWithCountry(
              controller: institutionNumberController,
              hintText: widget.institutionName,
              isReadOnly: true,
              textInputType: TextInputType.text,
              showCountryLabel: false,
            ),

            const SizedBox(height: 24),

            // Student ID
            Text(
              'Student ID',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ReuseableTextFieldWithCountry(
              controller: studentIdController,
              isReadOnly: false,
              hintText: '123 456 789',
              textInputType: TextInputType.number,
              showCountryLabel: false,
            ),
            const SizedBox(height: 24),

            // Service Type
            Text(
              'Service Type',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showServiceTypeModal(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2B2725) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedServiceType,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
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

            // Student ID (highlighted field)

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
              hintText: '500',
            ),
            const SizedBox(height: 50),

            // Continue Button
            FullWidthButton(
              text: 'Continue',
              onPressed: () {
                if (studentIdController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ReuseableTransactionDetailsScreen(
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
                              buildDetailRow(
                                'Student Details',
                                studentIdController.text,
                                isDark,
                              ),
                              buildDetailRow(
                                'Institution Name',
                                widget.institutionName,
                                isDark,
                              ),
                              buildDetailRow(
                                'Service Type',
                                selectedServiceType,
                                isDark,
                              ),
                              buildDetailRow(
                                'Amount',
                                '₦${amountController.text}',
                                isDark,
                              ),
                              buildDetailRow('Fee', '₦${serviceFee}', isDark),
                              Divider(),
                              buildDetailRow(
                                'Total',
                                '₦${(int.parse(amountController.text) + serviceFee)}',
                                isDark,
                                isTotal: true,
                              ),
                            ],
                            onButtonPressed: _handlePinEntry,
                          ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  _handlePinEntry() async {
    final pin = await BiometricTransactionPinModal.show(context);
    if (pin != null && pin.length == 4 && mounted) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => TransactionReceiptWidget(
                  headerText: 'Transaction',
                  amount: '${(int.parse(amountController.text) + serviceFee)}',
                  topDetails: [
                    TransactionDetail(
                      label: 'Student Details',
                      value: studentIdController.text,
                    ),
                    TransactionDetail(
                      label: 'Service',
                      value: selectedServiceType,
                    ),
                    TransactionDetail(
                      label: 'Amount',
                      value: '₦${amountController.text}',
                    ),
                    TransactionDetail(label: 'Fee', value: '₦$serviceFee'),
                    TransactionDetail(
                      label: 'Total Debit',
                      value:
                          '₦${(int.parse(amountController.text) + serviceFee)}',
                    ),
                  ],
                  bottomDetails: [
                    TransactionDetail(
                      label: 'Transaction ID',
                      value: 'TXN${DateTime.now().millisecondsSinceEpoch}',
                      showCopyIcon: true,
                    ),
                    TransactionDetail(
                      label: 'Instiution Name',
                      value: widget.institutionName,
                    ),
                    TransactionDetail(
                      label: 'Payment Source',
                      value: 'ValarPay Account',
                    ),
                    TransactionDetail(
                      label: 'Date & Time',
                      value: '29 Sep 2025 | 8:15 pm',
                    ),
                  ],
                  // onShareReceipt: () {},
                ),
          ),
        );
      }
    }
  }

  void _showServiceTypeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ServiceTypeModal(
            selectedType: selectedServiceType,
            onTypeSelected: (type) {
              setState(() {
                selectedServiceType = type;
              });
            },
          ),
    );
  }
}
