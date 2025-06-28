import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'coin_recommendation_screen.dart';

class InvestmentPortfolioScreen extends StatefulWidget {
  const InvestmentPortfolioScreen({super.key});

  @override
  _InvestmentPortfolioScreenState createState() =>
      _InvestmentPortfolioScreenState();
}

class _InvestmentPortfolioScreenState extends State<InvestmentPortfolioScreen> {
  Map<String, dynamic>? _answers;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnswers();
  }

  Future<void> _fetchAnswers() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Пользователь не найден.");
      }
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()!.containsKey('questionnaire_answers')) {
        setState(() {
          _answers = doc.data()!['questionnaire_answers'];
          _isLoading = false;
        });
      } else {
        throw Exception("Ответы на анкету не найдены.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки данных: ${e.toString()}')),
        );
      }
    }
  }

  // Simple logic to generate portfolio based on risk appetite
  Map<String, double> _generatePortfolio() {
    if (_answers == null || _answers!['risk_appetite_assets'] == null) {
      return {'BTC': 50, 'ETH': 30, 'Memcoins': 20}; // Default
    }
    int riskChoice = _answers!['risk_appetite_assets'];
    if (riskChoice == 0) { // High risk
      return {'Memcoins': 60, 'ETH': 25, 'BTC': 15};
    } else if (riskChoice == 1) { // Medium risk
      return {'BTC': 40, 'ETH': 40, 'Memcoins': 20};
    } else { // Low risk
      return {'BTC': 70, 'ETH': 25, 'Memcoins': 5};
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4B39EF);
    final portfolio = _generatePortfolio();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Ваш портфель',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _answers == null
              ? const Center(child: Text('Не удалось загрузить данные портфеля.'))
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'На основе ваших ответов, мы подобрали для вас следующий портфель:',
                        style: GoogleFonts.plusJakartaSans(fontSize: 18),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: ListView(
                          children: portfolio.entries.map((entry) {
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 15),
                              child: ListTile(
                                title: Text(entry.key, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                trailing: Text('${entry.value.toStringAsFixed(0)}%', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CoinRecommendationScreen(questionnaireAnswers: _answers!)),
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
                          'Купить',
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
