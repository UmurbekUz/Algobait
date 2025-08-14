import 'package:algobait/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:algobait/firebase_options.dart';
import 'package:algobait/services/currency_service.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure that widgets are initialized before running anything else
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from the .env file
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Run the app
  runApp(
    ChangeNotifierProvider(
      create: (context) => CurrencyService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algobait',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(primary: const Color(0xFF4B39EF)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Set SplashScreen as the starting point
    );
  }
}

