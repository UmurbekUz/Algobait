import 'package:algobait/screens/auth/login_screen.dart';
import 'package:algobait/screens/main/main_screen.dart';
import 'package:algobait/screens/profile/create_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in, check if profile exists
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                 return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (profileSnapshot.hasData && profileSnapshot.data!.exists) {
                // Profile exists, go to main screen with navigation
                return const MainScreen();
              } else {
                // Profile does not exist, go to create profile screen
                return const CreateProfileScreen();
              }
            },
          );
        }
        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}
