import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bybit_add_screen.dart';
import 'exchange_info_screen.dart';

class ExchangeConnectScreen extends StatelessWidget {
  const ExchangeConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF4B39EF);
    final List<String> exchanges = [
      'Bybit',
      'MEXC',
      'Bitget',
      'HTX',
      'KuCoin',
      'Gate.io'
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: primary, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Подключите биржу', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        itemCount: exchanges.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final exchangeName = exchanges[index];
          return _ExchangeButton(exchangeName: exchangeName);
        },
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
            MaterialPageRoute(
              builder: (_) => ExchangeInfoScreen(
                exchangeName: exchangeName,
                // For now, all exchanges will lead to BybitAddScreen after the info screen.
                // Later, we can create specific screens for each exchange.
                connectionScreen: BybitAddScreen(platformName: exchangeName),
              ),
            ),
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
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
