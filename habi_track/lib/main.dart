import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.instance.init();

  runApp(const HabiTrackApp());
}

class HabiTrackApp extends StatelessWidget {
  const HabiTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF4F93F9));

    return MaterialApp(
      title: 'HabiTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      home: const HomePage(),
    );
  }
}