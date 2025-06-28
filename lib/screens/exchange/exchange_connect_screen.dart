import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bybit_add_screen.dart';

class ExchangeConnectScreen extends StatelessWidget {
  const ExchangeConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF4B39EF);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: primary, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Подключите биржу', style: GoogleFonts.lato(color: primary, fontWeight: FontWeight.w800, fontSize: 22)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            _ExchangeButton(exchangeName: 'Bybit'),
            const SizedBox(height: 16),
            // TODO: Add other exchanges like Binance later
            // _ExchangeButton(exchangeName: 'Binance'),
          ],
        ),
      ),
    );
  }
}

class _ExchangeButton extends StatelessWidget {
  final String exchangeName;

  const _ExchangeButton({required this.exchangeName});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BybitAddScreen(platformName: exchangeName)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4B39EF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        child: Text(
          exchangeName,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
