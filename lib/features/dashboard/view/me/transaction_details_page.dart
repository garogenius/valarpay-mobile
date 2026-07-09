import 'package:flutter/material.dart';
import 'package:valarpay/features/models/transaction_model.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';

class TransactionDetailsPage extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailsPage({Key? key, required this.transaction})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTransfer = transaction.category.toUpperCase() == 'TRANSFER';
    final isBill = transaction.category.toUpperCase().contains('BILL');
    final isDeposit = transaction.category.toUpperCase() == 'DEPOSIT';

    List<Widget> topDetails = [];
    List<Widget> bottomDetails = [];
    String topTitle = '';
    String? bottomTitle;
    bool hasBottom = false;

    if (isTransfer && transaction.transferDetails != null) {
      topTitle = 'Transfer';
      topDetails = [
        buildDetailRow(
          'Amount',
          '₦${transaction.transferDetails!.amount}',
          false,
        ),
        buildDetailRow('Fee', '₦${transaction.transferDetails!.fee}', false),
        buildDetailRow('Status', transaction.status, false),
        buildDetailRow('Date', transaction.createdAt.toString(), false),
        buildDetailRow(
          'Sender Name',
          transaction.transferDetails!.senderName ?? '',
          false,
        ),
        buildDetailRow(
          'Sender Bank',
          transaction.transferDetails!.senderBankName ?? '',
          false,
        ),
        buildDetailRow(
          'Sender Account',
          transaction.transferDetails!.senderAccountNumber ?? '',
          false,
        ),
      ];
      hasBottom = true;
      bottomTitle = 'Beneficiary';
      bottomDetails = [
        buildDetailRow(
          'Bank',
          transaction.transferDetails!.beneficiaryBankName ?? '',
          false,
        ),
        buildDetailRow(
          'Account',
          transaction.transferDetails!.beneficiaryAccountNumber ?? '',
          false,
        ),
      ];
    } else if (isBill && transaction.billDetails != null) {
      // Use network if available (e.g. Airtel), otherwise provider (e.g. PalmPay)
      final rawProvider = transaction.billDetails!.network ??
          transaction.billDetails!.provider ??
          '';

      final provider = rawProvider.isNotEmpty
          ? rawProvider[0].toUpperCase() +
              (rawProvider.length > 1
                  ? rawProvider.substring(1).toLowerCase()
                  : '')
          : '';

      final rawType = (transaction.billDetails!.billType ?? '').trim().toUpperCase();

      String displayType;
      if (rawType == 'AIRTIME') {
        displayType = 'Airtime';
      } else if (rawType == 'DATA' || rawType == 'MOBILE_DATA') {
        displayType = 'Mobile Data';
      } else if (rawType.contains('CABLE') ||
          rawType.contains('TV') ||
          rawType.contains('CABLE_TV')) {
        displayType = 'Cable TV';
      } else if (rawType == 'ELECTRICITY') {
        displayType = 'Electricity';
      } else if (rawType == 'GIFTCARD' || rawType == 'GIFT_CARD') {
        displayType = 'Gift Card';
      } else if (rawType == 'INTERNATIONAL_AIRTIME') {
        displayType = 'Intl. Airtime';
      } else {
        // Fallback: Check description for keywords if billType is generic
        final desc = transaction.description.toUpperCase();
        if (desc.contains('AIRTIME')) {
          displayType = 'Airtime';
        } else if (desc.contains('DATA') || desc.contains('BUNDLE')) {
          displayType = 'Mobile Data';
        } else if (desc.contains('CABLE') || desc.contains('TV')) {
          displayType = 'Cable TV';
        } else if (desc.contains('ELECTRICITY') || desc.contains('POWER')) {
          displayType = 'Electricity';
        } else {
          displayType = transaction.billDetails!.billType ?? 'Bill Payment';
        }
      }

      if (provider.toLowerCase().contains('kuda')) {
        if (displayType == 'Airtime' || displayType == 'Intl. Airtime') {
          topTitle = 'Airtime purchase';
        } else if (displayType == 'Mobile Data') {
          topTitle = 'Data purchase';
        } else {
          topTitle = displayType;
        }
      } else {
        topTitle = provider.isEmpty ? displayType : '$provider $displayType';
      }

      topDetails = [
        buildDetailRow('Amount', '₦${transaction.billDetails!.amount}', false),
        buildDetailRow(
          'Provider',
          transaction.billDetails!.provider ?? '',
          false,
        ),
        buildDetailRow('Type', displayType, false),
        buildDetailRow('Status', transaction.status, false),
        buildDetailRow('Date', transaction.createdAt.toString(), false),
      ];
      hasBottom = false;
    } else if (isDeposit && transaction.depositDetails != null) {
      topTitle = 'Deposit';
      topDetails = [
        buildDetailRow(
          'Amount',
          '₦${transaction.depositDetails!.amount}',
          false,
        ),
        buildDetailRow(
          'Sender',
          transaction.depositDetails!.senderName ?? '',
          false,
        ),
        buildDetailRow('Status', transaction.status, false),
        buildDetailRow('Date', transaction.createdAt.toString(), false),
      ];
      hasBottom = false;
    } else {
      topTitle = transaction.category;
      topDetails = [
        buildDetailRow('Amount', '₦${transaction.amount}', false),
        buildDetailRow('Status', transaction.status, false),
        buildDetailRow('Date', transaction.createdAt.toString(), false),
      ];
      hasBottom = false;
    }

    return ReuseableTransactionDetailsScreen(
      totalAmount: 0.0,
      saveBeneficiary: false,
      onSaveBeneficiaryChanged: (value) {},
      topTransactionsDetailsList: topDetails,
      topTitleText: topTitle,
      hasBottom: hasBottom,
      bottomTitleText: bottomTitle,
      bottomTransactionsDetailsList: hasBottom ? bottomDetails : null,
      onButtonPressed: null,
      showActions: false,
    );
  }
}
