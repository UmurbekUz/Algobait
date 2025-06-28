import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../exchange/bybit_add_screen.dart';

class PlatformConnectScreen extends StatelessWidget {
  const PlatformConnectScreen({super.key});

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
        title: Text('Подключите платформу', style: GoogleFonts.lato(color: primary, fontWeight: FontWeight.w800, fontSize: 22)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            _PlatformButton(platformName: '3Commas'),
            const SizedBox(height: 16),
            _PlatformButton(platformName: 'Fatty.io'),
          ],
        ),
      ),
    );
  }
}

class _PlatformButton extends StatelessWidget {
  final String platformName;

  const _PlatformButton({required this.platformName});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BybitAddScreen(platformName: platformName)),
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
          platformName,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
