import 'package:algobait/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  Future<void> _goToHome(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_route', '/home');
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4B39EF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 30),
              Text(
                'Оплата прошла успешно!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Text(
                'Вы успешно инвестировали. Вы можете просмотреть детали в своем профиле.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () => _goToHome(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Перейти на главный экран', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
