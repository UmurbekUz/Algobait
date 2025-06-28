import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:algobait/screens/auth/auth_screen.dart';
import 'package:algobait/screens/profile/community_screen.dart';
import 'package:algobait/screens/profile/help_screen.dart';
import 'package:algobait/screens/profile/portfolio_screen.dart';
import 'package:algobait/screens/profile/security_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (currentUser == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B39EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                _buildProfileHeader(),
                Expanded(
                  child: _buildSettingsPane(),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader() {
    final imageBase64 = userData?['profile_picture_base64'] as String? ?? '';
    final name = userData?['name'] as String? ?? 'No Name';
    final email = currentUser?.email ?? 'No Email';

    ImageProvider? backgroundImage;
    if (imageBase64.isNotEmpty) {
      try {
        backgroundImage = MemoryImage(base64Decode(imageBase64));
      } catch (e) {
        print('Error decoding base64 image: $e');
        backgroundImage = null;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: backgroundImage,
            child: backgroundImage == null
                ? const Icon(Icons.person, size: 40, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildQuickAccessButtons(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _quickAccessButton(
          context,
          icon: Icons.account_balance_wallet,
          label: 'Портфель',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PortfolioScreen()),
            );
          },
        ),
        _quickAccessButton(
          context,
          icon: Icons.security,
          label: 'Безопасность',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SecurityScreen()),
            );
          },
        ),
        _quickAccessButton(
          context,
          icon: Icons.help_outline,
          label: 'Помощь',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _quickAccessButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPane() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройка',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsTile(icon: Icons.people_outline, title: 'Сообщество', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CommunityScreen()),
              );
            }),
            _buildSettingsTile(icon: Icons.exit_to_app, title: 'Выйти', onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (Route<dynamic> route) => false,
              );
            }),
            _buildSettingsTile(icon: Icons.add, title: 'Добавить аккаунт', onTap: () {}),
            _buildSettingsTile(icon: Icons.delete_outline, title: 'Удалить аккаунт', isDestructive: true, onTap: () {}),
            const SizedBox(height: 16),
            _buildDropdownTile(icon: Icons.language, title: 'Язык', value: 'Русский', options: ['Русский', 'English']),
            const SizedBox(height: 8),
            _buildDropdownTile(icon: FontAwesomeIcons.dollarSign, title: 'Валюта', value: 'USD', options: ['USD', 'EUR', 'RUB']),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required VoidCallback onTap, bool isDestructive = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.grey.shade600),
      title: Text(
        title,
        style: GoogleFonts.outfit(color: isDestructive ? Colors.red : Colors.black, fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile({required IconData icon, required String title, required String value, required List<String> options}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey.shade600, size: 20),
      title: Text(title, style: GoogleFonts.outfit(fontSize: 16)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isDense: true,
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: GoogleFonts.outfit()),
              );
            }).toList(),
            onChanged: (_) {},
          ),
        ),
      ),
    );
  }
}
