import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/core/utils/responsive_utils.dart';
import 'package:valarpay/core/widgets/kyc_not_set_widget.dart';
import 'package:valarpay/features/providers/user_provider.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final List<Map<String, dynamic>> withdrawOptions = [
    {
      "id": 1,
      "icon": Icons.account_balance,
      "title": "Withdraw via Bank Branch",
      "subtitle": "Withdraw cash easily from any bank branch",
    },
    {
      "id": 2,
      "icon": Icons.credit_card,
      "title": "Withdraw via ValarPay ATM",
      "subtitle": "Get instant cash anytime using your ValarPay card",
    },
    {
      "id": 3,
      "icon": Icons.store,
      "title": "Withdraw via Merchant",
      "subtitle": "Withdraw at authorized ValarPay merchants",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isBvnVerified = (user?.isBvnVerified ?? false) || (user?.isNinVerified ?? false) || (user?.wallets.isNotEmpty ?? false);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Withdraw",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontSize: 16.sp),
        ),
      ),
      body: !isBvnVerified
          ? const KycNotSetWidget(
              title: 'KYC Not Completed',
              subtitle: 'Complete your KYC verification to withdraw funds',
            )
          : Padding(
        padding: ResponsiveUtils.paddingAll16,
        child: Column(
          children:
              withdrawOptions.map((option) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: ResponsiveUtils.borderRadius12,
                  ),
                  child: ListTile(
                    contentPadding: ResponsiveUtils.paddingAll12,
                    leading: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: appTheme.primaryColor,
                      child: Icon(
                        option["icon"],
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    title: Text(
                      option["title"],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    subtitle: Text(
                      option["subtitle"],
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 13.sp),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onTap: () {
                      if (option['id'] == 1) {
                        context.push('/withdraw-via-bank');
                      } else if (option['id'] == 2) {
                        context.push(
                          '/coming-soon',
                          extra: 'Withdraw via ValarPay ATM',
                        );
                      } else if (option['id'] == 3) {
                        context.push(
                          '/coming-soon',
                          extra: 'Withdraw via Merchant',
                        );
                      }
                      // Handle navigation for each withdraw option
                    },
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
