import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../home/home_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  String _pin = '';
  String? _savedPin;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    _savedPin = await _storage.read(key: 'user_passcode');
    final biometricEnabledStr = await _storage.read(key: 'biometric_enabled');
    final biometricEnabled = biometricEnabledStr == 'true';

    if (_savedPin == null) {
      _navigateToHome();
      return;
    }

    if (biometricEnabled) {
      try {
        final didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Пожалуйста, подтвердите свою личность для входа',
          options: const AuthenticationOptions(biometricOnly: true),
        );
        if (didAuthenticate) {
          _navigateToHome();
        }
      } on PlatformException catch (e) {
        print('Biometric error: $e');
        // Fallback to PIN
      }
    }
    setState(() {}); // Rebuild to show PIN pad
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _onNumberPressed(String value) {
    if (_pin.length < 4) {
      setState(() {
        _pin += value;
      });

      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _verifyPin() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_pin == _savedPin) {
        _navigateToHome();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Неверный ПИН-код'), backgroundColor: Colors.red),
        );
        setState(() {
          _pin = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _savedPin == null
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4B39EF)))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Spacer(),
                    const Icon(Icons.lock_outline, size: 48, color: Color(0xFF4B39EF)),
                    const SizedBox(height: 24),
                    Text('Введите ПИН-код', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    _buildPinDots(),
                    const Spacer(),
                    _buildNumpad(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < _pin.length ? const Color(0xFF4B39EF) : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3'].map((e) => _buildNumpadButton(e)).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6'].map((e) => _buildNumpadButton(e)).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9'].map((e) => _buildNumpadButton(e)).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumpadButton('face_id'),
            _buildNumpadButton('0'),
            _buildNumpadButton('delete'),
          ],
        ),
      ],
    );
  }

  Widget _buildNumpadButton(String value) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Material(
        color: Colors.grey.shade100,
        shape: const CircleBorder(),
        child: InkWell(
          borderRadius: BorderRadius.circular(35),
          onTap: () {
            if (value == 'delete') {
              _onDeletePressed();
            } else if (value == 'face_id') {
              _authenticate();
            } else {
              _onNumberPressed(value);
            }
          },
          child: Center(
            child: value == 'delete'
                ? const Icon(Icons.backspace_outlined, color: Colors.black54)
                : value == 'face_id'
                    ? const Icon(Icons.face_retouching_natural, color: Colors.black54)
                    : Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
