import 'package:flutter/material.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';

class CurrentRateWidget extends StatelessWidget {
  final String text;
  final String price;
  final String symbol;
  const CurrentRateWidget({required this.price, required this.text, this.symbol = '₦', super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isDark ? Color(0XFF152432) : Color(0XFFd3E2f0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text,
                style: TextStyle(color: Color(0XFF216EB2), fontSize: 16)),
            Text(currencyFormatter(price, symbol: symbol),
                style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontSize: 14))
          ],
        ));
  }
}
