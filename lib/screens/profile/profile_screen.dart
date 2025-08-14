import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:algobait/screens/auth/auth_screen.dart';
import 'package:algobait/screens/profile/community_screen.dart';
import 'package:algobait/screens/profile/help_screen.dart';
import 'package:algobait/screens/profile/portfolio_screen.dart';
import 'package:algobait/screens/profile/security_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:algobait/services/currency_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  String? _profileImageBase64;
  bool isLoading = true;
  bool _isUploading = false;
  String _selectedLanguage = 'Русский';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();


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
      if (mounted) {
        setState(() {
          userData = doc.data();
          _profileImageBase64 = userData?['profile_picture_base64'];
          isLoading = false;
        });
      }
      } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось загрузить данные: $e')));
      }
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    if (_isUploading) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50, maxWidth: 500);

    if (pickedFile == null || !mounted) return;

    setState(() => _isUploading = true);

    try {
      final imageBytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(imageBytes);

      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'profile_picture_base64': base64String,
      });

      if (mounted) {
        setState(() {
          _profileImageBase64 = base64String;
        });
      }
  } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки изображения: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _deleteUserAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !mounted) return;

    try {
      // First, try to delete the user directly.
      await user.delete();
      // If successful, delete Firestore data and navigate.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      if (mounted) {
        _navigateToAuthScreen();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // If recent login is required, prompt for re-authentication.
        if (mounted) {
          _showReauthenticationDialog();
        }
      } else {
        // Handle other Firebase errors.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: ${e.message}')));
        }
      }
    } catch (e) {
      // Handle other general errors.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Произошла ошибка: $e')));
      }
    }
  }

  void _showReauthenticationDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Требуется повторная аутентификация'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Введите ваш пароль'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _reauthenticateAndDelete(passwordController.text);
              },
              child: const Text('Подтвердить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reauthenticateAndDelete(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    try {
      AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);

      // Re-authentication successful, now delete everything.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();

      if (mounted) {
        _navigateToAuthScreen();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка повторной аутентификации: ${e.message}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Произошла ошибка: $e')));
      }
    }
  }

  void _navigateToAuthScreen() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить аккаунт?'),
          content: const Text('Вы уверены? Все ваши данные, включая средства и портфель, будут удалены без возможности восстановления.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Удалить'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUserAccount();
              },
            ),
          ],
        );
      },
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF4B39EF)),
                title: Text('Галерея', style: GoogleFonts.outfit()),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFF4B39EF)),
                title: Text('Камера', style: GoogleFonts.outfit()),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentUser == null || userData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Не удалось загрузить данные пользователя.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                },
                child: const Text('На экран входа'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF4B39EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: _buildSettingsPane(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    String displayName = userData?['full_name'] ?? 'No Name';
    String email = currentUser?.email ?? 'No email';
    String? photoUrl = _profileImageBase64;
    ImageProvider? backgroundImage;
    if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
      backgroundImage = MemoryImage(base64Decode(_profileImageBase64!));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isUploading ? null : _showImagePickerOptions,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: backgroundImage,
                  child: (backgroundImage == null && !_isUploading)
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
                if (_isUploading)
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
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
    final currencyService = Provider.of<CurrencyService>(context);
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
               if (mounted) {
                 Navigator.of(context).pushAndRemoveUntil(
                   MaterialPageRoute(builder: (context) => const AuthScreen()),
                   (Route<dynamic> route) => false,
                 );
               }
             }),
            _buildSettingsTile(icon: Icons.add, title: 'Добавить аккаунт', onTap: () {}),
            _buildSettingsTile(icon: Icons.delete_outline, title: 'Удалить аккаунт', isDestructive: true, onTap: _showDeleteConfirmationDialog),
            const SizedBox(height: 16),
            Text(
              'Безопасность',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownTile(
              icon: Icons.language, 
              title: 'Язык', 
              value: _selectedLanguage, 
              options: ['Русский', 'English'],
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              }
            ),
            const SizedBox(height: 8),
            _buildDropdownTile(
              icon: FontAwesomeIcons.dollarSign,
              title: 'Валюта',
              value: currencyService.currentCurrency,
              options: const ['USD', 'EUR', 'RUB'],
              onChanged: (newValue) async {
                if (newValue != null) {
                  // Use listen: false in callbacks to prevent build errors
                  await Provider.of<CurrencyService>(context, listen: false).setCurrency(newValue);
                }
              },
            ),
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

  Widget _buildDropdownTile({required IconData icon, required String title, required String value, required List<String> options, required ValueChanged<String?> onChanged}) {
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
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
