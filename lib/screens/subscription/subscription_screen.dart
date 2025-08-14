import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/plan_model.dart';
import 'payment_screen.dart';


class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Plan _selectedPlan = Plan.pro; // Default selection

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4B39EF);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Выберите план', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Разблокируйте все возможности',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Выберите план, который подходит именно вам.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 30),
                      _buildSubscriptionOption(
                        plan: Plan.basic,
                        title: 'Basic',
                        price: '\$13.99',
                        period: '/ месяц',
                        features: ['Стратегии', 'Подбор инструмента'],
                        color: primaryColor,
                      ),
                      const SizedBox(height: 20),
                      _buildSubscriptionOption(
                        plan: Plan.pro,
                        title: 'Pro',
                        price: '\$21.99',
                        period: '/ месяц',
                        features: ['Все из Basic', 'Инвест. портфель', 'Торговый робот'],
                        color: primaryColor,
                        isRecommended: true,
                      ),
                      const SizedBox(height: 20),
                      _buildSubscriptionOption(
                        plan: Plan.premium,
                        title: 'Premium',
                        price: '\$230.99',
                        period: '/ год',
                        features: ['Все из Pro', 'Приоритетная поддержка'],
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(selectedPlan: _selectedPlan),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Продолжить',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Без покупки подписки использование приложения невозможно.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionOption({
    required Plan plan,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required Color color,
    bool isRecommended = false,
  }) {
    bool isSelected = _selectedPlan == plan;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Лучший выбор', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(price, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(width: 5),
                Text(period, style: GoogleFonts.outfit(fontSize: 16, color: Colors.black54)),
              ],
            ),
            const Divider(height: 30, thickness: 1),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(feature, style: GoogleFonts.outfit(fontSize: 16))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
