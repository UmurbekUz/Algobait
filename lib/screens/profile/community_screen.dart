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
            icon: FontAwesomeIcons.discord,
            text: 'Discord',
            onTap: () => _launchURL('https://discord.gg/ZUGcpcmW'),
          ),
          _buildCommunityTile(
            icon: FontAwesomeIcons.youtube,
            text: 'YouTube',
            onTap: () => _launchURL('https://youtube.com/@algobait?si=bk0GIvnOhn3gSzYH'),
          ),
          _buildCommunityTile(
            icon: FontAwesomeIcons.telegram,
            text: 'Телеграм канал',
            onTap: () => _launchURL('https://t.me/Algobait'),
            fontWeight: FontWeight.bold,
          ),
          _buildCommunityTile(
            icon: FontAwesomeIcons.xTwitter,
            text: 'X (Twitter)',
            onTap: () => _launchURL('https://x.com/algobait?s=21'),
          ),
          const Divider(height: 30, indent: 20, endIndent: 20),
          _buildCommunityTile(
            icon: Icons.share_outlined,
            text: 'Поделиться приложением',
            onTap: () {
              Share.share('https://algobait.tilda.ws/');
            },
            fontWeight: FontWeight.bold,
          ),
          _buildCommunityTile(
            icon: Icons.thumb_up_alt_outlined,
            text: 'Обратная связь',
            onTap: () {
               _launchURL('https://t.me/IvanEffimov');
            },
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTile({required IconData icon, required String text, required VoidCallback onTap, FontWeight fontWeight = FontWeight.w500}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: FaIcon(icon, color: const Color(0xFF4B39EF), size: 24),
      title: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: fontWeight,
        ),
      ),
      onTap: onTap,
    );
  }
}
