import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../home/home_screen.dart';

class SetPasscodeScreen extends StatefulWidget {
  const SetPasscodeScreen({super.key});

  @override
  State<SetPasscodeScreen> createState() => _SetPasscodeScreenState();
}

enum _PasscodeStatus { enter, confirm, success }

class _SetPasscodeScreenState extends State<SetPasscodeScreen> {
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  _PasscodeStatus _status = _PasscodeStatus.enter;
  String _pin = '';
  String _tempPin = '';
  bool _isBiometricEnabled = false;
  bool _canUseBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      setState(() {
        _canUseBiometrics = canCheck;
      });
    } catch (e) {
      print("Biometrik tekshirishda xato: $e");
    }
  }

  void _onNumberPressed(String value) {
    if (_pin.length < 4) {
      setState(() {
        _pin += value;
      });

      if (_pin.length == 4) {
        _handlePinCompleted();
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

  void _handlePinCompleted() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_status == _PasscodeStatus.enter) {
        setState(() {
          _tempPin = _pin;
          _pin = '';
          _status = _PasscodeStatus.confirm;
        });
      } else if (_status == _PasscodeStatus.confirm) {
        if (_pin == _tempPin) {
          _savePasscode();
        } else {
          // Show error and reset
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ПИН-коды не совпадают. Попробуйте снова.'), backgroundColor: Colors.red),
          );
          setState(() {
            _pin = '';
            _tempPin = '';
            _status = _PasscodeStatus.enter;
          });
        }
      }
    });
  }

  Future<void> _savePasscode() async {
    await _storage.write(key: 'user_passcode', value: _pin);
    await _storage.write(key: 'biometric_enabled', value: _isBiometricEnabled.toString());
    setState(() {
      _status = _PasscodeStatus.success;
    });
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Установить ПИН-код',
          style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: _status != _PasscodeStatus.success,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _status == _PasscodeStatus.success ? _buildSuccessView() : _buildPasscodeView(),
        ),
      ),
    );
  }

  Widget _buildPasscodeView() {
    String title;
    if (_status == _PasscodeStatus.enter) {
      title = 'Создайте ПИН-код';
    } else {
      title = 'Подтвердите ПИН-код';
    }

    return Column(
      children: [
        const Spacer(),
        Text(title, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildPinDots(),
        const Spacer(),
        if (_canUseBiometrics)
          _buildBiometricSwitch(),
        const SizedBox(height: 20),
        _buildNumpad(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
        const SizedBox(height: 24),
        Text(
          'ПИН-код успешно установлен!',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Теперь вы можете использовать его для входа в приложение.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey.shade600),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: _navigateToHome,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4B39EF),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Перейти на главный экран', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        ),
        const SizedBox(height: 40),
      ],
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

  Widget _buildBiometricSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Вход по Face ID / отпечатку', style: GoogleFonts.outfit(fontSize: 16)),
        const SizedBox(width: 10),
        Switch(
          value: _isBiometricEnabled,
          onChanged: (value) {
            setState(() {
              _isBiometricEnabled = value;
            });
          },
          activeColor: const Color(0xFF4B39EF),
        ),
      ],
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
            const SizedBox(width: 70, height: 70),
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
            } else {
              _onNumberPressed(value);
            }
          },
          child: Center(
            child: value == 'delete'
                ? const Icon(Icons.backspace_outlined, color: Colors.black54)
                : Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
