import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:algobait/screens/profile/security/change_password_screen.dart';
import 'package:algobait/screens/profile/security/change_email_screen.dart';
import 'package:algobait/screens/profile/security/link_phone_screen.dart';
import 'package:algobait/screens/profile/security/biometric_auth_screen.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

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
          'Безопасность',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSecurityOption(
            context,
            title: 'Изменить пароль',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
            },
          ),
          _buildSecurityOption(
            context,
            title: 'Эл. почта',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeEmailScreen()));
            },
          ),
          _buildSecurityOption(
            context,
            title: 'Мобильный',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LinkPhoneScreen()));
            },
          ),
          _buildSecurityOption(
            context,
            title: 'Биометрическая аутентификация',
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const BiometricAuthScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOption(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
