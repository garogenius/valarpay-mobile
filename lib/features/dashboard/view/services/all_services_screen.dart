import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valarpay/features/models/transaction_model.dart';
import 'package:valarpay/features/notifiers/transaction_notifier.dart';

class AllServicesScreen extends ConsumerStatefulWidget {
  const AllServicesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends ConsumerState<AllServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(transactionNotifierProvider).data == null ||
          ref.read(transactionNotifierProvider).data!.isEmpty) {
        ref
            .read(transactionNotifierProvider.notifier)
            .fetchTransactions(limit: 50);
      }
    });
  }

  List<ServiceItem> _getRecentServices(List<TransactionModel> transactions) {
    final recentServices = <ServiceItem>[];
    final seenTypes = <String>{};

    for (final tx in transactions) {
      if (recentServices.length >= 4) break;

      // Check for Bill Payments
      if (tx.category == 'BILL_PAYMENT' || tx.category == 'BILL') {
        final billType = tx.billDetails?.billType?.toUpperCase() ?? '';
        
        if (billType.isEmpty || seenTypes.contains(billType)) continue;

        ServiceItem? item;
        if (billType.contains('AIRTIME')) {
          item = ServiceItem(
            icon: 'assets/images/service_icon/airtime.svg',
            label: 'Airtime',
            onTap: () => context.push('/airtime'),
          );
        } else if (billType.contains('DATA')) {
          item = ServiceItem(
            icon: 'assets/images/service_icon/Data.svg',
            label: 'Data',
            onTap: () => context.push('/data'),
          );
        } else if (billType.contains('BETTING')) {
          item = ServiceItem(
            icon: 'assets/images/service_icon/betting.svg',
            label: 'Betting',
            onTap: () => context.push('/betting'),
          );
        } else if (billType.contains('ELECTRICITY')) {
          item = ServiceItem(
            icon: 'assets/images/service_icon/light.svg',
            label: 'Electricity',
            onTap: () => context.push('/electricity'),
          );
        } else if (billType.contains('CABLE') || billType.contains('TV')) {
          item = ServiceItem(
            icon: 'assets/images/service_icon/cable.svg',
            label: 'TV',
            onTap: () => context.push('/cable-tv'),
          );
        } else if (billType.contains('INTERNET')) {
          item = ServiceItem(
            icon: 'assets/images/service_icon/internet.svg',
            label: 'Internet',
            onTap: () => context.push('/internet'),
          );
        } else if (billType.contains('EDUCATION') || 
                   billType.contains('SCHOOL')) {
          item = ServiceItem(
            icon: 'assets/images/service_icon/Education.svg',
            label: 'Education',
            onTap: () => context.push('/remita-billing/6/Educational Institutions'),
          );
        } else if (billType.contains('WAEC') || 
                   billType.contains('JAMB')) {
          item = ServiceItem(
            icon: 'assets/images/service_icon/Education.svg',
            label: 'Exam Pins',
            onTap: () => context.push('/education'),
          );
        } else if (billType.contains('TRANSPORT')) {                                                              
          item = ServiceItem(
            icon: 'assets/images/service_icon/flight.svg',
            label: 'Transport',
            onTap: () => context.push('/flutterwave-billing/TRANSPORT/Transport'),
          );
        } else if (billType.contains('TAX')) {
          item = ServiceItem(
            icon: 'assets/images/service_icon/shoping.svg',
            label: 'Pay Tax',
            onTap: () => context.push('/flutterwave-billing/TAX/Pay Tax'),
          );
        } else if (billType.contains('GOVERNMENT') || billType.contains('GOV')) {
          item = ServiceItem(
            icon: 'assets/images/service_icon/shoping.svg',
            label: 'Gov Fees',
            onTap: () => context.push('/coming-soon'),
          );
        }

        if (item != null) {
          recentServices.add(item);
          seenTypes.add(billType);
        }
      }
    }

    // Default if empty
    if (recentServices.isEmpty) {
      return [
        ServiceItem(
          icon: 'assets/images/service_icon/airtime.svg',
          label: 'Airtime',
          onTap: () => context.push('/airtime'),
        ),
        ServiceItem(
          icon: 'assets/images/service_icon/Data.svg',
          label: 'Data',
          onTap: () => context.push('/data'),
        ),
        ServiceItem(
          icon: 'assets/images/service_icon/betting.svg',
          label: 'Betting',
          onTap: () => context.push('/betting'),
        ),
      ];
    }

    return recentServices;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionState = ref.watch(transactionNotifierProvider);
    final transactions = transactionState.data ?? [];

    final categories = [
      ServiceCategory(
        title: 'Recently Used',
        items: _getRecentServices(transactions),
      ),
      ServiceCategory(
        title: 'Financial Assets',
        items: [
          ServiceItem(
            icon: 'assets/images/service_icon/int.svg',
            label: 'Invest',
            onTap: () => context.push('/invest'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/Data.svg',
            label: 'Easylife Savings',
            onTap: () => context.push('/finance/easylife/intro'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/cable.svg',
            label: 'Fixed Savings',
            onTap: () => context.push('/finance/savings/fixed/plans'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/light.svg',
            label: 'Target Saving',
            onTap: () => context.push('/finance/savings/target/plans'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/cable.svg',
            label: 'Fixed Deposit',
            onTap: () => context.push('/finance/fixed-deposit/plans'),
          ),

          ServiceItem(
            icon: 'assets/images/service_icon/Insurance.svg',
            label: 'Insurance',
            onTap: () => context.push('/coming-soon'),
          ),
        ],
      ),
      ServiceCategory(
        title: 'Bill Payments',
        items: [
          // ServiceItem(
          //   icon: 'assets/images/service_icon/shoping.svg',
          //   label: 'All Bills',
          //   onTap: () => context.push('/remita-categories'),
          // ),
          ServiceItem(
            icon: 'assets/images/service_icon/airtime.svg',
            label: 'Airtime',
            onTap: () => context.push('/airtime'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/Data.svg',
            label: 'Data',
            onTap: () => context.push('/data'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/betting.svg',
            label: 'Betting',
            onTap: () => context.push('/betting'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/light.svg',
            label: 'Electricity',
            onTap: () => context.push('/electricity'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/cable.svg',
            label: 'TV',
            onTap: () => context.push('/cable-tv'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/gift.svg',
            label: 'Gift Card',
            onTap: () => context.push('/gift-card'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/internet.svg',
            label: 'Internet',
            onTap: () => context.push('/internet'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/Education.svg',
            label: 'Education',
            onTap: () => context.push('/remita-billing/education/Educational Institutions'),
          ),
          // ServiceItem(
          //   icon: 'assets/images/service_icon/Education.svg',
          //   label: 'Exam Pins',
          //   onTap: () => context.push('/education'),
          // ),
          ServiceItem(
            icon: 'assets/images/service_icon/Education.svg',
            label: 'School Fees',
            onTap: () => context.push('/flutterwave-billing/SCHPB/School Fees'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/int.svg',
            label: 'Intl Airtime',
            onTap: () => context.push('/international-airtime'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/flight.svg',
            label: 'Flight',
            onTap: () => context.push('/flight'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/flight.svg',
            label: 'Transport',
            onTap: () => context.push('/flutterwave-billing/TRANSLOG/Transport'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/shoping.svg',
            label: 'Pay Tax',
            onTap: () => context.push('/flutterwave-billing/TAX/Pay Tax'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/shoping.svg',
            label: 'Gov Fees',
            onTap: () =>
                context.push('/coming-soon'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/shoping.svg',
            label: 'TSA/State',
            onTap: () => context.push('/coming-soon'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/shoping.svg',
            label: 'Hospital',
            onTap: () => context.push('/coming-soon'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/shoping.svg',
            label: 'Water Bill',
            onTap: () => context.push('/coming-soon'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/arrow-swap-horizontal.svg',
            label: 'Swap',
            onTap: () => context.push('/swap-currency'),
          ),
          ServiceItem(
            icon: 'assets/images/service_icon/shoping.svg',
            label: 'Shopping',
            onTap: () => context.push('/shopping'),
          ),
          // ServiceItem(
          //   icon: 'assets/images/service_icon/Insurance.svg',
          //   label: 'Insurance',
          //   onTap: () => context.push('/coming-soon'),
          // ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'All Services',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black, size: 20.w),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCategorySection(context, categories[index]);
        },
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, ServiceCategory category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? appTheme.darkColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: category.items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 8.w,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              return _buildServiceItem(context, category.items[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, ServiceItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: item.onTap,
      child: Column(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: appTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                item.icon,
                width: 20.w,
                height: 20.w,
                colorFilter: const ColorFilter.mode(
                  appTheme.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCategory {
  final String title;
  final List<ServiceItem> items;

  ServiceCategory({required this.title, required this.items});
}

class ServiceItem {
  final String icon;
  final String label;
  final VoidCallback onTap;

  ServiceItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

