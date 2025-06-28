import 'package:algobait/screens/payment/payment_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> questionnaireAnswers;
  final String recommendedCoin;

  const PaymentScreen({
    super.key,
    required this.questionnaireAnswers,
    required this.recommendedCoin,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isConsentGiven = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4B39EF);
    final budget = widget.questionnaireAnswers['budget'] ?? 'не указан';

    InputDecoration buildInputDecoration(String label, {String? hint}) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.plusJakartaSans(color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Оплата', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Вы инвестируете $budget USD в ${widget.recommendedCoin}.',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('По карте', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    TextFormField(
                      decoration: buildInputDecoration('Card number'),
                      keyboardType: TextInputType.number,
                      validator: (value) => (value?.isEmpty ?? true) ? 'Введите номер карты' : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: buildInputDecoration('Exp. Date', hint: 'MM/YY'),
                            keyboardType: TextInputType.datetime,
                            validator: (value) => (value?.isEmpty ?? true) ? 'Введите дату' : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            decoration: buildInputDecoration('CVV'),
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            validator: (value) => (value?.isEmpty ?? true) ? 'Введите CVV' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            CheckboxListTile(
              title: const Text('Я подтверждаю, что совершаю эту инвестицию по собственному желанию и осознаю все риски.'),
              value: _isConsentGiven,
              onChanged: (bool? value) {
                setState(() {
                  _isConsentGiven = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: primaryColor,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _isConsentGiven ? _processPayment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: Colors.grey,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Оплатить $budget USD', style: GoogleFonts.plusJakartaSans(fontSize: 18, color: Colors.white)),
                  ),
          ],
        ),
      ),
    );
  }
}
