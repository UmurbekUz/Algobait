import 'package:algobait/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:algobait/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:algobait/services/currency_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize CurrencyService before running the app
  final currencyService = CurrencyService();
  await currencyService.init();

  runApp(
    ChangeNotifierProvider.value(
      value: currencyService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

