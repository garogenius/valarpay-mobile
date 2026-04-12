import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newValueText = newValue.text.replaceAll(',', '');

    if (newValueText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    double value = double.tryParse(newValueText) ?? 0.0;
    
    // Formatting the number with commas
    final formatter = NumberFormat('#,###');
    String formattedValue = formatter.format(value);
    
    if (newValueText.endsWith('.')) {
      formattedValue += '.';
    } else {
      List<String> parts = newValueText.split('.');
      if (parts.length > 1) {
        formattedValue += '.${parts[1]}';
      }
    }

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}

String currencyFormatter(dynamic amount, {String symbol = '₦'}) {
  if (amount == null) return '${symbol}0.00';

  String strAmount = amount.toString();
  if (strAmount.isEmpty) return '${symbol}0.00';

  // Remove existing symbol and commas
  String cleanAmount = strAmount.replaceAll(symbol, '').replaceAll(',', '').trim();

  if (cleanAmount.isEmpty) return '${symbol}0.00';

  try {
    double value = double.parse(cleanAmount);
    final formatter = NumberFormat('#,###.00', 'en_US');
    String formattedValue = formatter.format(value);

    return '$symbol$formattedValue';
  } catch (e) {
    return strAmount.contains(symbol) ? strAmount : '$symbol$strAmount';
  }
}

