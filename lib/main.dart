import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import '../app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
]);
  final container = ProviderContainer();
  await container.read(userProvider.notifier).loadUser();
  runApp(UncontrolledProviderScope(container: container, child: Listener(child: MyApp())));
}
