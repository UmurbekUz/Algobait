import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../profile/create_profile_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    _timer =
        Timer.periodic(const Duration(seconds: 3), (_) => _checkVerification());
  }

  Future<void> _checkVerification() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      _timer.cancel();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'вашу почту';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Подтвердите ваш email',
                style: GoogleFonts.readexPro(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Мы отправили письмо для подтверждения на адрес:\n$email',
                textAlign: TextAlign.center,
                style: GoogleFonts.readexPro(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Ожидание подтверждения...',
                style: GoogleFonts.readexPro(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser
                      ?.sendEmailVerification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Письмо отправлено повторно')),
                    );
                  }
                },
                child: const Text('Отправить письмо еще раз'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
