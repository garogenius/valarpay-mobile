import 'dart:math';

import 'package:intl/intl.dart';

class Helpers {
  static String formatAmount(String amount) {
    final _formatter = NumberFormat('#,###');
    final raw = amount.replaceAll(',', '').replaceAll(' ', '');
    if (raw.isEmpty) amount;
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) amount;
    final formatted = _formatter.format(int.parse(digits));
    return formatted.toString();
  }

  static double parsedAmount(String amount) {
    final raw = amount.replaceAll(',', '').trim();
    return double.tryParse(raw) ?? 0.0;
  }

  static String getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  static String generateTransferRef() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    final code =
        List.generate(12, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'TRF-$code';
  }

  static String formatTo11(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('234')) {
      digits = '0${digits.substring(3)}';
    }
    if (digits.length > 11) {
      digits = digits.substring(digits.length - 11);
    }
    return digits;
  }
}
