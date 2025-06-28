import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
          'Пароль для входа в систему',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordField(
              label: 'Старый пароль',
              hint: 'Введите пароль',
              isVisible: _isOldPasswordVisible,
              onToggleVisibility: () {
                setState(() => _isOldPasswordVisible = !_isOldPasswordVisible);
              },
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              label: 'Новый пароль',
              hint: 'Введите пароль',
              isVisible: _isNewPasswordVisible,
              onToggleVisibility: () {
                setState(() => _isNewPasswordVisible = !_isNewPasswordVisible);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Text(
                'От 8 до 32 цифр, по крайней мере 1 цифра, 1 заглавная буква и 1 Специальные символы',
                style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              label: 'Подтвердите новый пароль',
              hint: 'Введите пароль',
              isVisible: _isConfirmPasswordVisible,
              onToggleVisibility: () {
                setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Отправить',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey.shade600,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}
