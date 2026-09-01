import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/login_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  runApp(const SkipCashApp());
}

class SkipCashApp extends StatelessWidget {
  const SkipCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkipCash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Cairo',
      ),
      home: const LoginScreen(),
    );
  }
}
