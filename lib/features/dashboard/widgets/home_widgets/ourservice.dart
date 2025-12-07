import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/color_utils.dart';

class OurServicesWidget extends StatelessWidget {
  const OurServicesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ServiceItem> services = [
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
        onTap: () => context.push('/coming-soon'),
      ),
      ServiceItem(
        icon: 'assets/images/service_icon/light.svg',
        label: 'Electricity',
        onTap: () => context.push('/electricity'),
      ),
      ServiceItem(
        icon: 'assets/images/service_icon/cable.svg',
        label: 'Cable Tv',
        onTap: () => context.push('/cable-tv'),
      ),
      ServiceItem(
        icon: 'assets/images/service_icon/arrow-swap-horizontal.svg',
        label: 'Swap Currency',
        onTap: () => context.push('/swap-currency'),
        // onTap: () => context.push('/coming-soon'),
      ),
      ServiceItem(
        icon: 'assets/images/service_icon/internet.svg',
        label: 'Internet',
        onTap: () => context.push('/internet'),
      ),
      ServiceItem(
        icon: 'assets/images/service_icon/gift.svg',
        label: 'Giftcard',
        onTap: () => context.push('/gift-card'),
      ),
      ServiceItem(
        icon: 'assets/images/service_icon/int.svg',
        label: 'Intl. Airtime',
        // onTap: () => context.push('/coming-soon'),
        onTap: () => context.push('/international-airtime'),
      ),
      ServiceItem(
        icon: 'assets/images/service_icon/Education.svg',
        label: 'Education',
        onTap: () => context.push('/education'),
      ),
      ServiceItem(
        icon: 'assets/images/service_icon/shoping.svg',
        label: 'Shopping',
        onTap: () => context.push('/coming-soon'),
      ),
      ServiceItem(
        icon: 'assets/images/service_icon/Insurance.svg',
        label: 'Insurance',
        onTap: () => context.push('/coming-soon'),
      ),
      ServiceItem(
        icon: 'assets/images/service_icon/flight.svg',
        label: 'Flight',
        onTap: () => context.push('/coming-soon'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            'Our Services',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 22 / 18,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 100, // adaptive
              crossAxisSpacing: 8,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return _buildServiceItem(
                context,
                services[index],
                services[index].onTap,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    ServiceItem service,
    Function() onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: appTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: SvgPicture.asset(
                  service.icon,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFF76301),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 14 / 10,
                letterSpacing: 0.1,
                color: isDark ? const Color(0xFFF9FAFB) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceItem {
  final String icon;
  final String label;
  final Function() onTap;

  const ServiceItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
