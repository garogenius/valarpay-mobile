import 'package:flutter/material.dart';
import 'package:valarpay/core/widgets/responsive_text_field.dart';
import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
import 'package:valarpay/features/dashboard/widgets/services_widgets/flight_widgets/class_selector_modal.dart';
import '../../../widgets/services_widgets/swap_currency_widgets/payment_method_modal.dart';

class BeneficiaryAccountDetailsScreen extends StatelessWidget {
  final Map<String, String> transactionData;

  BeneficiaryAccountDetailsScreen({super.key, required this.transactionData});
  final TextEditingController controller = TextEditingController();

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: [
                ResponsiveTextField(
                  controller: controller,
                  hint: 'Input beneficiary account number',
                  label: 'Beneficiary Account Number',

                  //  textInputType: TextInputType.name,
                  // showCountryLabel: false,
                ),

                // const Spacer(),

                // Pay Via section
                const SizedBox(height: 24),

                const SizedBox(height: 8),

                ResponsiveTextField(
                  controller: controller,
                  hint: 'Valarpay',
                  label: 'Beneficiary Bank Name',
                  readOnly: true,

                  //  textInputType: TextInputType.name,
                  // showCountryLabel: false,
                ),
                const SizedBox(height: 60),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // _showPaymentMethodModal(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF76301),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm Swap',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentOptionSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ClassSelectorModal(
            selectedClass: "selectedClass",
            onClassSelected: (classType) {
              // setState(() {
              //   selectedClass = classType;
              // });
            },
          ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isDark, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(
    String name,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        const Icon(Icons.star, color: Color(0xFFF76301), size: 20),
      ],
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '';
    }
  }

  String _calculateTotal() {
    double fromAmount =
        double.tryParse(transactionData['fromAmount'] ?? '0') ?? 0;
    double serviceFee = 50;
    return (fromAmount + serviceFee).toStringAsFixed(2);
  }

  void _showPaymentMethodModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => SwapCurrencyPaymentMethodModal(
            transactionData: transactionData,
            onPaymentMethodSelected: (method) {
              // Handle payment method selection
            },
          ),
    );
  }
}
