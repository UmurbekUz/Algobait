import 'dart:async';
import 'package:flutter/material.dart';
import 'package:algobait/screens/auth/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {
    // Perform all necessary initializations here
    try {
      await dotenv.load(fileName: "config.env");
      await Firebase.initializeApp();
    } catch (e) {
      print('Error during initialization: $e');
      // Handle initialization error, maybe show an error message
    }

    // Ensure the splash screen is visible for a minimum duration
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => const AuthWrapper(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/logoanimation.gif'),
      ),
    );
  }
}
