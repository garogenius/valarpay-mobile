import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/core/utils/currency_formatter.dart';
import 'package:valarpay/core/widgets/transaction_receipt_widget.dart';
import 'package:valarpay/core/widgets/shareable_transaction_receipt.dart';
import 'package:valarpay/core/widgets/transaction_details_screen.dart';

class CoralPaySuccessScreen extends StatelessWidget {
  final String amount;
  final List<TransactionDetail> topDetails;
  final List<TransactionDetail> bottomDetails;
  final List<ShareableTransactionReceiptDetail> shareableDetails;

  const CoralPaySuccessScreen({
    super.key,
    required this.amount,
    required this.topDetails,
    required this.bottomDetails,
    required this.shareableDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Dynamic Success Icon with Outer Rings
              Stack(
                alignment: Alignment.center,
                children: [
                   Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.1),
                    ),
                  ),
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.2),
                    ),
                  ),
                  Container(
                    width: 70.w,
                    height: 70.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 40.sp),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              Text(
                'Transaction Successful',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Your payment has been processed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                currencyFormatter(amount),
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFF76301),
                ),
              ),
              const Spacer(),
              
              // View Receipt Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionReceiptWidget(
                          headerText: 'Payment Receipt',
                          amount: amount,
                          topDetails: topDetails,
                          bottomDetails: bottomDetails,
                          shareableDetails: shareableDetails,
                          receiptDate: topDetails.firstWhere((e) => e.label == 'Date', orElse: () => TransactionDetail(label: '', value: '')).value,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF76301),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'View Receipt',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Done Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
