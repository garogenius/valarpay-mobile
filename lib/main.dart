import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:valarpay/core/services/local_notification_service.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import '../app.dart';

// Background message handler - must be top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp();
  
  debugPrint('📩 Handling background message: ${message.notification?.title}');
  debugPrint('📩 Message data: ${message.data}');
  
  // You can show a notification here if needed
  // await LocalNotificationService.showNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (with error handling)
  try {
    // Try to initialize with default platform configuration
    // This uses GoogleService-Info.plist on iOS and google-services.json on Android
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully');
    
    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint('✅ Background message handler registered');
    
    // Initialize local notifications
    await LocalNotificationService.initialize();
    debugPrint('✅ Local notifications initialized');
    
  } catch (e) {
    // Firebase initialization failed - app will continue without FCM
    debugPrint('ℹ️ Firebase initialization failed');
    debugPrint('ℹ️ Error: ${e.toString().split('\n').first}');
    debugPrint('ℹ️ Continuing without FCM push notifications');
    debugPrint('ℹ️ In-app notifications will still work via API');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final container = ProviderContainer();
  await container.read(userProvider.notifier).loadUser();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: Listener(child: MyApp()),
    ),
  );
}
