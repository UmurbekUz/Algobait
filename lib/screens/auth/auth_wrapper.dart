import 'package:algobait/screens/auth/auth_screen.dart';
import 'package:algobait/screens/auth/verify_email_screen.dart';
import 'package:algobait/screens/home/home_screen.dart';
import 'package:algobait/screens/profile/create_profile_screen.dart';
import 'package:algobait/screens/subscription/subscription_screen.dart';
import 'package:algobait/screens/exchange/exchange_connect_screen.dart';
import 'package:algobait/screens/platform/platform_connect_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Widget> _getScreenForVerifiedUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final lastRoute = prefs.getString('last_route');

    final profileDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!profileDoc.exists) {
      return const CreateProfileScreen();
    }

    if (lastRoute != null) {
      switch (lastRoute) {
        case '/create-profile':
          return const CreateProfileScreen();
        case '/subscription':
          return const SubscriptionScreen();
        case '/exchange-connect':
          return const ExchangeConnectScreen();
        case '/platform-connect':
          return const PlatformConnectScreen();
        case '/home':
          return const HomeScreen();
        default:
          return const HomeScreen();
      }
    } else {
      return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        debugPrint('[AuthWrapper] Rebuilding. User is present: ${snapshot.hasData}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;

          // First and most important: check if email is verified.
          if (!user.emailVerified) {
            return const VerifyEmailScreen();
          }

          // If email is verified, proceed to find the correct screen.
          return FutureBuilder<Widget>(
            future: _getScreenForVerifiedUser(user),
            builder: (context, screenSnapshot) {
              if (screenSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return screenSnapshot.data ?? const AuthScreen(); // Fallback
            },
          );
        }

        // User is not logged in
        return const AuthScreen();
      },
    );
  }
}
