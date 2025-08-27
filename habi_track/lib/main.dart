import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB5K95kls15pl-GQhiBAgVYhW08ym8k2uA",
      authDomain: "habitrack-5f7fd.firebaseapp.com",
      projectId: "habitrack-5f7fd",
      storageBucket: "habitrack-5f7fd.appspot.com",
      messagingSenderId: "176300134015",
      appId: "1:176300134015:web:3353624c82891c0785394a",
      measurementId: "G-N4J2GXXKGD",
    ),
  );
  runApp(const HabiTrackApp());
}

class HabiTrackApp extends StatelessWidget {
  const HabiTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabiTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}