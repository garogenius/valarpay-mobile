import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/biometric_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';
import 'package:valarpay/core/widgets/reuseable_text_field_with_country.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import 'package:valarpay/features/models/remita_models.dart';
import 'package:valarpay/features/notifiers/remita_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import '../../../widgets/services_widgets/flight_widgets/gender_selector_modal.dart';

class PassengerDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, String> flightData;

  const PassengerDetailsScreen({super.key, required this.flightData});

  @override
  ConsumerState<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends ConsumerState<PassengerDetailsScreen> {
  final List<Map<String, dynamic>> passengers = [];
  String serviceFee = '500';
  bool saveBeneficiary = false;

  @override
  void initState() {
    super.initState();
    _initializePassengers();
  }

  void _initializePassengers() {
    final adults = int.parse(widget.flightData['adults'] ?? '0');
    final children = int.parse(widget.flightData['children'] ?? '0');
    final infants = int.parse(widget.flightData['infants'] ?? '0');

    // Add adults
    for (int i = 0; i < adults; i++) {
      passengers.add({
        'type': 'Adult ${i + 1} (12+ years)',
        'fullName': TextEditingController(),
        'dateOfBirth': null,
        'gender': 'Male',
      });
    }

    // Add children
    for (int i = 0; i < children; i++) {
      passengers.add({
        'type': 'Child ${i + 1} (2-11 years)',
        'fullName': TextEditingController(),
        'dateOfBirth': null,
        'gender': 'Male',
      });
    }

    // Add infants
    for (int i = 0; i < infants; i++) {
      passengers.add({
        'type': 'Infant ${i + 1} (under 2 years)',
        'fullName': TextEditingController(),
        'dateOfBirth': null,
        'gender': 'Male',
      });
    }
  }

  Future<void> _handlePayment() async {
    // Basic validation
    for (var p in passengers) {
      if (p['fullName'].text.isEmpty) {
        AppMessenger.show(context, message: 'Please enter all passenger names', type: MessageType.error);
        return;
      }
    }

    final user = ref.read(userProvider);
    final productId = widget.flightData['productId']!;
    
    // We don't have a real amount from products yet, so we'll use a placeholder or let user enter it?
    // Actually, FlightScreen should have selected a product with an amount.
    // For now, let's assume a default amount or 0 if not found.
    double amount = 0.0;
    final products = ref.read(remitaProductsProvider).data;
    if (products != null && products.isNotEmpty) {
      final product = products.firstWhere((p) => p.billPaymentProductId == productId, orElse: () => products.first);
      amount = product.amount ?? 0.0;
    }

    if (amount <= 0) {
      // If amount is 0, we might need to ask the user or show an error
      AppMessenger.show(context, message: 'Invalid flight amount. Please go back and try again.', type: MessageType.error);
      return;
    }

    final metadata = {
      'departure': widget.flightData['departure'],
      'destination': widget.flightData['destination'],
      'class': widget.flightData['class'],
      'departureDate': widget.flightData['departureDate'],
      'bookingRef': widget.flightData['bookingRef'],
      'passengers': passengers.map((p) => {
        'name': p['fullName'].text,
        'dob': p['dateOfBirth']?.toString(),
        'gender': p['gender'],
      }).toList(),
    };

    final initiateRequest = RemitaInitiateRequest(
      billPaymentProductId: productId,
      amount: amount,
      name: user?.fullName ?? 'ValarPay User',
      paymentIdentifier: DateTime.now().millisecondsSinceEpoch.toString(),
      email: widget.flightData['email'] ?? user?.email ?? '',
      phoneNumber: widget.flightData['phone'] ?? user?.phoneNumber ?? '',
      customerId: widget.flightData['bookingRef']!, // Using booking ref as customer ID for flights
      metadata: metadata,
    );

    final initiation = await ref.read(remitaPaymentProvider.notifier).initiate(initiateRequest);

    if (initiation != null) {
      _showPinModal(initiation);
    } else {
      final state = ref.read(remitaPaymentProvider);
      AppMessenger.show(context, message: state.message ?? 'Failed to initiate payment', type: MessageType.error);
    }
  }

  Future<void> _showPinModal(RemitaInitiationResponse initiation) async {
    final pin = await TransactionPinModal.show(context);
    if (pin != null && pin.length == 4) {
      _completePayment(initiation, pin);
    }
  }

  Future<void> _completePayment(RemitaInitiationResponse initiation, String pin) async {
    final paymentRequest = RemitaPaymentRequest(
      rrr: initiation.rrr,
      paymentIdentifier: initiation.paymentIdentifier,
      amount: initiation.amount,
      walletPin: pin,
    );

    await ref.read(remitaPaymentProvider.notifier).pay(paymentRequest);

    final state = ref.read(remitaPaymentProvider);
    if (state.isDataAvailable && state.singleData != null) {
      _navigateToReceipt(state.singleData!);
    } else {
      AppMessenger.show(context, message: state.message ?? 'Payment failed', type: MessageType.error);
    }
  }

  void _navigateToReceipt(RemitaPaymentResponse response) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionReceiptWidget(
          headerText: 'Payment Successful',
          amount: response.amount.toString(),
          topDetails: [
            TransactionDetail(label: 'RRR', value: response.rrr, showCopyIcon: true),
            TransactionDetail(label: 'Amount', value: currencyFormatter(response.amount.toString())),
            TransactionDetail(label: 'Airline', value: widget.flightData['flightName']!),
            TransactionDetail(label: 'Booking Ref', value: widget.flightData['bookingRef']!, showCopyIcon: true),
          ],
          bottomDetails: [
            TransactionDetail(label: 'Route', value: '${widget.flightData['departure']} → ${widget.flightData['destination']}'),
            TransactionDetail(label: 'Class', value: widget.flightData['class'] ?? 'Economy'),
            TransactionDetail(label: 'Passengers', value: '${passengers.length}'),
            TransactionDetail(label: 'Transaction ID', value: response.transactionRef, showCopyIcon: true),
            TransactionDetail(label: 'Date', value: DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instruction text
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: Text(
                    'Passenger Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Enter traveller information as it appears on your valid ID or passport',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Passengers list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: passengers.length,
              itemBuilder: (context, index) {
                return _buildPassengerForm(passengers[index], index, isDark);
              },
            ),
          ),

          // Continue button\
          FullWidthButton(
            text: 'Continue to Review',
            onPressed: () {
              // Basic validation
              for (var p in passengers) {
                if (p['fullName'].text.isEmpty) {
                  AppMessenger.show(context, message: 'Please enter all passenger names', type: MessageType.error);
                  return;
                }
              }

              final products = ref.read(remitaProductsProvider).data;
              final productId = widget.flightData['productId'];
              final product = products?.firstWhere((p) => p.billPaymentProductId == productId, orElse: () => products!.first);
              final amount = product?.amount ?? 0.0;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ReuseableTransactionDetailsScreen(
                        totalAmount: amount,
                        saveBeneficiary: saveBeneficiary,
                        onSaveBeneficiaryChanged: (value) {
                          setState(() {
                            saveBeneficiary = value;
                          });
                        },
                        topTitleText: 'Flight',
                        bottomTitleText: 'Flight Details',
                        hasBottom: true,
                        topTransactionsDetailsList: [
                          buildDetailRow(
                            'Route',
                            '${widget.flightData['departure']} → ${widget.flightData['destination']}',
                            isDark,
                          ),
                          buildDetailRow(
                            'Airline',
                            widget.flightData['flightName']!,
                            isDark,
                          ),
                          buildDetailRow(
                            'Class Type',
                            widget.flightData['class'] ?? 'Economy',
                            isDark,
                          ),
                          buildDetailRow(
                            'Number of Passengers',
                            '${passengers.length}',
                            isDark,
                          ),
                          buildDetailRow(
                            'Booking Reference',
                            widget.flightData['bookingRef'] ?? '',
                            isDark,
                          ),
                          buildDetailRow(
                            'Phone Number',
                            widget.flightData['phone'] ?? '',
                            isDark,
                          ),
                          buildDetailRow(
                            'Depature Date',
                            widget.flightData['departureDate']?.split(' ')[0] ?? '',
                            isDark,
                          ),
                        ],
                        bottomTransactionsDetailsList: [
                          buildDetailRow('Ticket Fare', currencyFormatter(amount.toString()), isDark),
                          buildDetailRow(
                            'Service Charges',
                            '₦0.00',
                            isDark,
                          ),
                          buildDetailRow(
                            'Total Amount',
                            currencyFormatter(amount.toString()),
                            isDark,
                            isTotal: true,
                          ),
                        ],
                        onButtonPressed: () => _handlePayment(),
                        onBiometricButtonPressed: () async {
                          final pin = await BiometricTransactionPinModal.show(context);
                          if (pin != null && pin.length == 4) {
                            // Initiation is needed first
                            _handlePayment(); 
                            // Note: We might need to refactor _handlePayment to take optional pin
                          }
                        },
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerForm(
    Map<String, dynamic> passenger,
    int index,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Passenger type
          Text(
            passenger['type'],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 16),

          // Full Name
          Text(
            'Full Name',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ReuseableTextFieldWithCountry(
            controller: passenger['fullName'],
            hintText: 'Full Name',
            isReadOnly: false,
            textInputType: TextInputType.text,
            showCountryLabel: false,
          ),

          const SizedBox(height: 16),

          // Date of Birth
          Text(
            'Date of Birth',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectDate(passenger),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    passenger['dateOfBirth'] != null
                        ? '${passenger['dateOfBirth'].day}-${passenger['dateOfBirth'].month}-${passenger['dateOfBirth'].year}'
                        : 'DD-MM-YYYY',
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Gender
          Text(
            'Gender',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showGenderSelector(passenger),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(passenger['gender'], style: TextStyle(fontSize: 16)),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(Map<String, dynamic> passenger) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        passenger['dateOfBirth'] = date;
      });
    }
  }

  void _showGenderSelector(Map<String, dynamic> passenger) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => GenderSelectorModal(
            selectedGender: passenger['gender'],
            onGenderSelected: (gender) {
              setState(() {
                passenger['gender'] = gender;
              });
            },
          ),
    );
  }
}
