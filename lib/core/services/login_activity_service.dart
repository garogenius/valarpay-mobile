import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valarpay/features/models/login_activity.dart';

class LoginActivityService {
  static const String _key = 'login_activity_history';
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<void> trackLogin(String status) async {
    try {
      final activity = await _createCurrentActivity(status);
      final list = await getHistory();
      list.insert(0, activity);
      
      // Limit to last 50 entries
      final limitedList = list.length > 50 ? list.sublist(0, 50) : list;
      
      final prefs = await SharedPreferences.getInstance();
      final jsonList = limitedList.map((e) => e.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    } catch (e) {
      // Silently fail, we don't want to block login for tracking failure
    }
  }

  static Future<List<LoginActivity>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => LoginActivity.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<LoginActivity> _createCurrentActivity(String status) async {
    String deviceName = 'Unknown Device';
    String deviceId = 'Unknown ID';

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      deviceName = iosInfo.name;
      deviceId = iosInfo.identifierForVendor ?? 'Unknown ID';
    }

    return LoginActivity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      deviceName: deviceName,
      deviceId: deviceId,
      status: status,
      isCurrentDevice: true,
      location: 'Lagos, Nigeria', // Mock for now, typical for these apps
      ipAddress: '192.168.1.1', // Placeholder
    );
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
