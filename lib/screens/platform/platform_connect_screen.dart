import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'platform_add_screen.dart';

class PlatformConnectScreen extends StatelessWidget {
  final List<String> connectedPlatforms;
  const PlatformConnectScreen({super.key, this.connectedPlatforms = const []});

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF4B39EF);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text('Подключите платформу', style: GoogleFonts.lato(color: primary, fontWeight: FontWeight.w800, fontSize: 22)),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              if (!connectedPlatforms.contains('3Commas')) ...[
                _PlatformButton(platformName: '3Commas', connected: connectedPlatforms),
                const SizedBox(height: 16),
              ],
              
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformButton extends StatelessWidget {
  final String platformName;
  final List<String> connected;

  const _PlatformButton({required this.platformName, required this.connected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlatformAddScreen(platformName: platformName, connectedPlatforms: connected)),
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
