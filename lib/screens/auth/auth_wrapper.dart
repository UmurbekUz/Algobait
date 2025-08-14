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
import 'package:algobait/screens/portfolio/investment_portfolio_screen.dart';
import 'package:algobait/screens/questionnaire/questionnaire_screen.dart';
import 'package:algobait/screens/auth/lock_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (authSnapshot.hasData) {
          final user = authSnapshot.data!;

          if (!user.emailVerified) {
            return const VerifyEmailScreen();
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (!userDocSnapshot.hasData || !userDocSnapshot.data!.exists) {
                return const CreateProfileScreen();
              }

              final data = userDocSnapshot.data!.data() as Map<String, dynamic>;

              // Check if onboarding is complete
              if (data.containsKey('onboarding_completed') && data['onboarding_completed'] == true) {
                return const LockScreen();
              }

              // Onboarding flow checks
              if (!data.containsKey('full_name')) {
                return const CreateProfileScreen();
              }
              if (!data.containsKey('bybit_connected') || data['bybit_connected'] != true) {
                return const ExchangeConnectScreen();
              }
              final connectedPlatforms = List<String>.from(data['connected_platforms'] ?? []);
              if (connectedPlatforms.length < 2) {
                return PlatformConnectScreen(connectedPlatforms: connectedPlatforms);
              }
              if (!data.containsKey('questionnaire_answers')) {
                return const QuestionnaireScreen();
              }
              if (!data.containsKey('is_subscribed') || data['is_subscribed'] != true) {
                return const SubscriptionScreen();
              }
              if (!data.containsKey('purchased_portfolio')) {
                return const InvestmentPortfolioScreen();
              }
              return const HomeScreen();
            },
          );
        }
        return const AuthScreen();
      },
    );
  }
}
