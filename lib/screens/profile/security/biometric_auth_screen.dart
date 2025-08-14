import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:algobait/services/biometric_service.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  bool _isEnabled = false;
  bool _canCheck = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initBiometricState();
  }

  Future<void> _initBiometricState() async {
    final canCheck = await BiometricService.canCheckBiometrics();
    final enabled = await BiometricService.isBiometricAuthEnabled();
    if (mounted) {
      setState(() {
        _canCheck = canCheck;
        _isEnabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (!_canCheck) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Биометрия не найдена на этом устройстве.')),
      );
      return;
    }
    await BiometricService.setBiometricAuthEnabled(value);
    if (mounted) {
      setState(() {
        _isEnabled = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4B39EF);

    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
              'Вы можете включить разблокировку приложения с помощью Face ID или отпечатка пальца.',
              style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(Icons.fingerprint, color: Colors.grey.shade600),
              title: Text('Вход по Face ID/Отпечатку', style: GoogleFonts.outfit(fontSize: 16)),
              value: _isEnabled,
              onChanged: _toggleBiometric,
              activeColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}



