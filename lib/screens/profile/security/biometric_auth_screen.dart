import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BiometricAuthScreen extends StatelessWidget {
  const BiometricAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4B39EF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Биометрическая аутентификация',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'После блокировки вы сможете разблокировать с помощью следующих способов аутентификации.',
              style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              shadowColor: Colors.grey.withOpacity(0.2),
              child: ListTile(
                title: Text('Face ID', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
