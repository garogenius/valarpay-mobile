import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/dashboard_provider.dart';
import '../../../../core/services/dashboard_service.dart';

class ThemesPage extends ConsumerWidget {
  const ThemesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Themes',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.43,
            letterSpacing: 0.035,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose the look that suits you best',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : const Color(0xFF9CA3AF),
                  fontFamily: 'SF Pro',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                  letterSpacing: 0.035,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context).cardColor
                      : const Color(0xFFFAFBFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildThemeOption(
                      context,
                      ref,
                      title: 'Dark Mode',
                      themeMode: ThemeMode.dark,
                      isSelected: currentThemeMode == ThemeMode.dark,
                      showDivider: true,
                      isDark: isDark,
                    ),
                    SizedBox(height: 12),
                    _buildThemeOption(
                      context,
                      ref,
                      title: 'Light Mode',
                      themeMode: ThemeMode.light,
                      isSelected: currentThemeMode == ThemeMode.light,
                      showDivider: true,
                      isDark: isDark,
                    ),
                    SizedBox(height: 12),
                    _buildThemeOption(
                      context,
                      ref,
                      title: 'System Default',
                      subtitle: 'This will use your device settings',
                      themeMode: ThemeMode.system,
                      isSelected: currentThemeMode == ThemeMode.system,
                      showDivider: false,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Dashboard Customize',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : const Color(0xFF9CA3AF),
                  fontFamily: 'SF Pro',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                  letterSpacing: 0.035,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context).cardColor
                      : const Color(0xFFFAFBFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final currentWidget = ref.watch(dashboardProvider);
                    return Column(
                      children: [
                        _buildDashboardOption(
                          context,
                          ref,
                          title: 'Slider Banner',
                          type: DashboardWidgetType.banner,
                          isSelected: currentWidget == DashboardWidgetType.banner,
                          showDivider: true,
                          isDark: isDark,
                        ),
                        _buildDashboardOption(
                          context,
                          ref,
                          title: 'Recent Transactions',
                          type: DashboardWidgetType.transactions,
                          isSelected: currentWidget == DashboardWidgetType.transactions,
                          showDivider: true,
                          isDark: isDark,
                        ),
                        _buildDashboardOption(
                          context,
                          ref,
                          title: 'None',
                          type: DashboardWidgetType.none,
                          isSelected: currentWidget == DashboardWidgetType.none,
                          showDivider: false,
                          isDark: isDark,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required DashboardWidgetType type,
    required bool isSelected,
    required bool showDivider,
    required bool isDark,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            await ref.read(dashboardProvider.notifier).setWidgetType(type);
            if (context.mounted) {
              AppMessenger.show(
                context,
                type: MessageType.success,
                message: 'Dashboard updated to $title',
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF111827),
                      fontFamily: 'SF Pro',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? appTheme.primaryColor
                          : (isDark ? Colors.grey[600]! : const Color(0xFF6B7280)),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: appTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 1,
              color: isDark ? Colors.grey[700] : const Color(0xFFF1F4FB),
            ),
          ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    String? subtitle,
    required ThemeMode themeMode,
    required bool isSelected,
    required bool showDivider,
    required bool isDark,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            // Update the theme using the new theme notifier
            await ref.read(themeProvider.notifier).setThemeMode(themeMode);

            // Show a toast to indicate the theme change
            if (context.mounted) {
              AppMessenger.show(
                context,
                type: MessageType.success,
                message: 'Theme changed to ${title.toLowerCase()}',
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF111827),
                          fontFamily: 'SF Pro',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.035,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey[400]
                                : const Color(0xFF9CA3AF),
                            fontFamily: 'SF Pro',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                            letterSpacing: 0.06,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Radio button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? appTheme.primaryColor
                          : (isDark
                              ? Colors.grey[600]!
                              : const Color(0xFF6B7280)),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: appTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 1,
              color: isDark ? Colors.grey[700] : const Color(0xFFF1F4FB),
            ),
          ),
      ],
    );
  }
}
