import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import '../app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (with error handling for dummy config)
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed (using dummy config): $e');
    // Continue anyway - FCM features won't work but app will run
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
