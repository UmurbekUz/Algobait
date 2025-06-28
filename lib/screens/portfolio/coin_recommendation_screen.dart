import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:algobait/screens/payment/payment_screen.dart';

class CoinRecommendationScreen extends StatelessWidget {
  final Map<String, dynamic> questionnaireAnswers;

  const CoinRecommendationScreen({super.key, required this.questionnaireAnswers});

  // Simple logic to get recommendation
  String _getRecommendedCoin() {
    int riskChoice = questionnaireAnswers['risk_appetite_assets'] ?? 2;
    if (riskChoice == 0) return 'Dogecoin (DOGE)'; // High risk
    if (riskChoice == 1) return 'Ethereum (ETH)'; // Medium risk
    return 'Bitcoin (BTC)'; // Low risk
  }

  String _getInvestmentPeriod() {
    int periodChoice = questionnaireAnswers['investment_period'] ?? 0;
    const periods = [
        'до 3 месяцев',
        'от 3 месяцев до 1 года',
        '1-5 лет',
        '5-10 лет',
        '+10 лет',
    ];
    return periods[periodChoice];
  }

  String _getRecommendationReason() {
     int riskChoice = questionnaireAnswers['risk_appetite_assets'] ?? 2;
     if (riskChoice == 0) return 'Ваш выбор указывает на высокую толерантность к риску. Dogecoin - это высоковолатильный актив, который может принести значительную прибыль, но сопряжен с высокими рисками.';
     if (riskChoice == 1) return 'Ethereum является основой для многих DeFi и NFT проектов, предлагая хороший баланс между потенциалом роста и установленной технологией. Это сбалансированный выбор.';
     return 'Bitcoin - самая устоявшаяся и наименее волатильная криптовалюта, что соответствует вашему желанию сохранить капитал. Это надежный выбор для долгосрочных инвестиций.';
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4B39EF);
    final budget = questionnaireAnswers['budget'] ?? 'не указан';
    final investmentPeriod = _getInvestmentPeriod();
    final recommendedCoin = _getRecommendedCoin();
    final reason = _getRecommendationReason();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Рекомендация',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Мы рекомендуем: $recommendedCoin',
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'На основе вашего бюджета в $budget USD и инвестиционного горизонта в $investmentPeriod, мы предлагаем следующий план:',
              style: GoogleFonts.plusJakartaSans(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Почему именно этот коин:',
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              reason,
              style: GoogleFonts.plusJakartaSans(fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      questionnaireAnswers: questionnaireAnswers,
                      recommendedCoin: recommendedCoin,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Инвестировать',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
