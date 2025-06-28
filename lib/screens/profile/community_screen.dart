import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Could not launch the URL
      print('Could not launch $url');
    }
  }

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
          'Сообщество',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        children: [
          _buildCommunityTile(
            icon: FontAwesomeIcons.twitter,
            text: 'Twitter',
            onTap: () => _launchURL('https://twitter.com/'), // TODO: Replace with actual URL
          ),
          _buildCommunityTile(
            icon: FontAwesomeIcons.telegram,
            text: 'Телеграм канал',
            onTap: () => _launchURL('https://t.me/'), // TODO: Replace with actual URL
          ),
          _buildCommunityTile(
            icon: FontAwesomeIcons.discord,
            text: 'Discord',
            onTap: () => _launchURL('https://discord.com/'), // TODO: Replace with actual URL
          ),
          _buildCommunityTile(
            icon: FontAwesomeIcons.youtube,
            text: 'YouTube',
            onTap: () => _launchURL('https://youtube.com/'), // TODO: Replace with actual URL
          ),
          const Divider(height: 30, indent: 20, endIndent: 20),
          _buildCommunityTile(
            icon: Icons.share_outlined,
            text: 'Поделиться приложением',
            onTap: () {
              Share.share('Check out this cool app! https://example.com'); // TODO: Replace with app link
            },
          ),
          _buildCommunityTile(
            icon: Icons.thumb_up_alt_outlined,
            text: 'Обратная связь',
            onTap: () {
               _launchURL('mailto:support@example.com?subject=App Feedback'); // TODO: Replace with support email
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTile({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: FaIcon(icon, color: const Color(0xFF4B39EF), size: 24),
      title: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
