import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dashboard_service.dart';

class DashboardNotifier extends StateNotifier<DashboardWidgetType> {
  DashboardNotifier() : super(DashboardWidgetType.banner) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final type = await DashboardService.getWidgetType();
    state = type;
  }

  Future<void> setWidgetType(DashboardWidgetType type) async {
    state = type;
    await DashboardService.setWidgetType(type);
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardWidgetType>((ref) {
  return DashboardNotifier();
});
