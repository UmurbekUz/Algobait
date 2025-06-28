import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/auth/verify_email_screen.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Registers a user or handles existing unverified user.
  static Future<void> signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user?.sendEmailVerification();

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // If the error is that the email is already in use
      if (e.code == 'email-already-in-use') {
        // Try to sign in the user instead
        try {
          final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
          // If sign-in is successful, check if the email is verified
          if (userCredential.user != null && !userCredential.user!.emailVerified) {
            // If not verified, resend verification and go to verify screen
            await userCredential.user!.sendEmailVerification();
            if (context.mounted) {
              _showError(context, 'Аккаунт уже существует, но не подтвержден. Повторно отправлено письмо для подтверждения.');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
              );
            }
          } else {
            // If already verified, show an error
            if (context.mounted) {
              _showError(context, 'Этот email уже зарегистрирован и подтвержден. Пожалуйста, войдите.');
            }
          }
        } on FirebaseAuthException catch (signInError) {
          // Handle sign-in errors (e.g., wrong password)
          if (context.mounted) {
            _showError(context, signInError.message ?? 'Ошибка входа');
          }
        }
      } else {
        // For any other sign-up errors, display them
        if (context.mounted) {
          _showError(context, e.message ?? 'Ошибка регистрации');
        }
      }
    }
  }

  /// Signs in; if not verified, go to verification screen.
  static Future<void> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _showError(context, e.message ?? 'Sign-in error');
    }
  }

  static void _showError(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
