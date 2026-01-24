import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:home_service/pages/onboarding/onboatding_screen.dart';
import 'package:home_service/services/notification_service.dart';
import 'package:home_service/services/admin_setup.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create default admin account
  await AdminSetup.createDefaultAdminIfNeeded();

  // Initialize notifications (skip for web as it requires service worker setup)
  if (!kIsWeb) {
    NotificationService notificationService = NotificationService();
    await notificationService.initializeNotifications();
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HomlyPro',
      home: OnboatdingScreen1(),
    );
  }
}
