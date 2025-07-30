import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/plan_model.dart';
import 'payment_success_screen.dart';
import 'widgets/card_number_formatter.dart';
import 'widgets/expiry_date_formatter.dart';

class PaymentScreen extends StatefulWidget {
  final Plan selectedPlan;

  const PaymentScreen({super.key, required this.selectedPlan});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  String _getPlanName(Plan plan) {
    switch (plan) {
      case Plan.basic: return 'Basic';
      case Plan.pro: return 'Pro';
      case Plan.premium: return 'Premium';
    }
  }

  String _getPlanPrice(Plan plan) {
    switch (plan) {
      case Plan.basic: return '\$13.99';
      case Plan.pro: return '\$21.99';
      case Plan.premium: return '\$230.99';
    }
  }

  String _getPlanPeriod(Plan plan) {
    switch (plan) {
      case Plan.premium: return 'год';
      default: return 'месяц';
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4B39EF);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Оплата', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPlanSummary(primaryColor),
                const SizedBox(height: 30),
                _buildCardDetailsForm(primaryColor),
                const SizedBox(height: 40),
                _buildPayButton(primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSummary(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('План', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 5),
              Text(
                _getPlanName(widget.selectedPlan),
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Цена', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 5),
              Text(
                _getPlanPrice(widget.selectedPlan),
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetailsForm(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Данные карты', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildTextFormField(
          label: 'Номер карты',
          hint: 'XXXX XXXX XXXX XXXX',
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          formatter: CardNumberFormatter(),
          validator: (value) {
            if (value == null || value.replaceAll(' ', '').length != 16) {
              return 'Введите 16-значный номер карты';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextFormField(
                label: 'Срок действия',
                hint: 'ММ/ГГ',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                formatter: ExpiryDateFormatter(),
                validator: (value) {
                  if (value == null || value.length != 5) {
                    return 'Введите дату в формате ММ/ГГ';
                  }
                  final parts = value.split('/');
                  if (parts.length != 2) {
                    return 'Неверный формат';
                  }

                  final month = int.tryParse(parts[0]);
                  final year = int.tryParse(parts[1]);

                  if (month == null || year == null) {
                    return 'Неверный формат';
                  }

                  if (month < 1 || month > 12) {
                    return 'Неверный месяц';
                  }

                  final currentYear = DateTime.now().year % 100;
                  final currentMonth = DateTime.now().month;

                  if (year < currentYear || (year == currentYear && month < currentMonth)) {
                    return 'Срок действия карты истек';
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildTextFormField(
                label: 'CVV',
                hint: 'XXX',
                icon: Icons.lock,
                keyboardType: TextInputType.number,
                isObscure: true,
                validator: (value) {
                  if (value == null || value.length != 3) {
                    return 'Введите 3-значный CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    TextInputFormatter? formatter,
    bool isObscure = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      obscureText: isObscure,
      inputFormatters: formatter != null ? [formatter] : [],
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4B39EF), width: 2),
        ),
      ),
    );
  }

  Widget _buildPayButton(Color primaryColor) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // Simulate payment processing
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                planName: _getPlanName(widget.selectedPlan),
                planPrice: _getPlanPrice(widget.selectedPlan),
                planPeriod: _getPlanPeriod(widget.selectedPlan),
              ),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
      child: Text(
        'Оплатить ${_getPlanPrice(widget.selectedPlan)}',
        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
