import 'package:shared_preferences/shared_preferences.dart';

enum DashboardWidgetType { banner, transactions, kyc, none }

class DashboardService {
  static const String _widgetTypeKey = 'dashboard_widget_type';

  static Future<DashboardWidgetType> getWidgetType() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_widgetTypeKey);

    if (index == null) {
      return DashboardWidgetType.banner;
    }

    return DashboardWidgetType.values[index];
  }

  static Future<void> setWidgetType(DashboardWidgetType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_widgetTypeKey, type.index);
  }
}
