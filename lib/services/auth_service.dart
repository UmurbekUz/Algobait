import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/auth/lock_screen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Registers a user or handles existing unverified user.
  static Future<void> signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;

      if (user != null) {
        // Create a document for the user with basic info
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await user.sendEmailVerification();
      }

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
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LockScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(context, e.message ?? 'Sign-in error');
    }
  }

  static void _showError(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  /// Sign in with Google and save user data if new.
  static Future<UserCredential?> signInWithGoogle({required BuildContext context}) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // After sign-in, save user data to Firestore if it's a new user
      if (userCredential.user != null) {
        await _saveSocialUserData(userCredential.user!);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _showError(context, e.message ?? 'Ошибка входа через Google');
      return null;
    } catch (e) {
      _showError(context, 'Произошла ошибка: ${e.toString()}');
      return null;
    }
  }

  /// Sign in with Apple and save user data if new.
  static Future<UserCredential?> signInWithApple({required BuildContext context}) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuthCredential from the Apple credential.
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // After sign-in, save user data to Firestore if it's a new user.
      if (userCredential.user != null) {
        await _saveSocialUserData(userCredential.user!);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _showError(context, e.message ?? 'Ошибка входа через Apple');
      return null;
    } catch (e) {
      _showError(context, 'Произошла ошибка: ${e.toString()}');
      return null;
    }
  }


  /// Helper method to save user data from social sign-ins.
  static Future<void> _saveSocialUserData(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      // User is new, create a document
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
