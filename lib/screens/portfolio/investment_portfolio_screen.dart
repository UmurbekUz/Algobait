import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:algobait/screens/auth/set_passcode_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:algobait/screens/home/home_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';

class InvestmentPortfolioScreen extends StatefulWidget {
  const InvestmentPortfolioScreen({super.key});

  @override
  _InvestmentPortfolioScreenState createState() =>
      _InvestmentPortfolioScreenState();
}

class _InvestmentPortfolioScreenState extends State<InvestmentPortfolioScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final Map<String, double> _mockAssetPrices = {
    'BTC': 50000.0,
    'ETH': 3000.0,
    'Memcoins': 0.001, // Mock price for the 'Memcoins' category
  };
  static const Map<String, String> _assetRationales = {
    'BTC': 'Основа стабильного портфеля. Низкий риск, долгосрочный рост.',
    'ETH': 'Доступ к экосистеме смарт-контрактов и DeFi. Средний риск.',
    'Memcoins': 'Высокий риск и высокая потенциальная доходность. Для агрессивных инвесторов.'
  };

  static const List<String> _allMemecoins = [
    'DOGE', 'SHIB', 'PEPE', 'WIF', 'BONK', 'FLOKI', 'BOME', 'MEME', 'BABYDOGE',
    'MOG', 'COQ', 'TURBO', 'POPCAT', 'MYRO', 'SLERF', 'TRUMP', 'PORK',
    'WEN', 'ZYN', 'PONKE', 'BOBO', 'PEPECOIN', 'KISHU', 'SAMO', 'HOGE',
    'MONA', 'BAN', 'CUMMIES', 'PIT', 'ELON', 'LEASH', 'AKITA', 'SAITAMA',
    'VOLT', 'LUFFY', 'KUMA', 'PULI', 'MARVIN', 'CAT', 'TSUKA', 'CULT',
    'GM', 'VINU', 'SHIK', 'YOOSHI', 'QUACK', 'PIG', 'FEG', 'SANSHU', 'HINA'
  ];
  Map<String, dynamic>? _answers;
  bool _isLoading = true;
  bool _isBuying = false;
  bool _showChart = true;

  final Map<String, Color> _assetColors = {
    'BTC': Colors.orange,
    'ETH': const Color(0xFF627EEA),
    'Memcoins': Colors.teal,
  };
  final Map<String, IconData> _assetIcons = {
    'BTC': FontAwesomeIcons.bitcoin,
    'ETH': FontAwesomeIcons.ethereum,
    'Memcoins': FontAwesomeIcons.rocket,
  };
  static const Map<String, String> _assetFullNames = {
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'Memcoins': 'Memcoins',
  };

  @override
  void initState() {
    super.initState();
    _fetchAnswers();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
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

  Map<String, Map<String, dynamic>> _generatePortfolio() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {}; // Should not happen if we are on this screen

    // Seed the random generator with the user's UID for consistent randomness per user
    final random = Random(user.uid.hashCode);

    Map<String, double> basePercentages;
    int riskChoice = _answers?['risk_appetite_assets'] ?? 1; // Default to medium risk

    if (riskChoice == 0) { // High risk
      basePercentages = {'Memcoins': 60, 'ETH': 25, 'BTC': 15};
    } else if (riskChoice == 1) { // Medium risk
      basePercentages = {'BTC': 40, 'ETH': 40, 'Memcoins': 20};
    } else { // Low risk
      basePercentages = {'BTC': 70, 'ETH': 25, 'Memcoins': 5};
    }

    // Slightly randomize percentages to make each portfolio unique
    double btcRand = (random.nextDouble() * 4.0) - 2.0; // -2.0 to +2.0
    double ethRand = (random.nextDouble() * 4.0) - 2.0;
    double memRand = (random.nextDouble() * 4.0) - 2.0;

    double btc = (basePercentages['BTC']! + btcRand).clamp(5.0, 80.0);
    double eth = (basePercentages['ETH']! + ethRand).clamp(5.0, 80.0);
    double mem = (basePercentages['Memcoins']! + memRand).clamp(1.0, 70.0);

    // Normalize to 100%
    double total = btc + eth + mem;
    final finalPercentages = {
      'BTC': (btc / total) * 100,
      'ETH': (eth / total) * 100,
      'Memcoins': (mem / total) * 100,
    };

    // Select a random subset of memcoins
    final shuffledMemecoins = List<String>.from(_allMemecoins)..shuffle(random);
    final selectedMemecoins = shuffledMemecoins.take(random.nextInt(3) + 5).toList(); // 5 to 7 coins

    return {
      for (var entry in finalPercentages.entries)
        entry.key: {
          'percentage': entry.value,
          'rationale': _assetRationales[entry.key] ?? 'Нет данных.',
          if (entry.key == 'Memcoins') 'selected_coins': selectedMemecoins,
        }
    };
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4B39EF);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (_answers == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ошибка'),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const Center(child: Text('Не удалось загрузить данные анкеты.')),
      );
    }
    
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
        actions: [
          IconButton(
            icon: Icon(_showChart ? Icons.pie_chart : Icons.pie_chart_outline, color: Colors.black),
            onPressed: () {
              setState(() {
                _showChart = !_showChart;
              });
            },
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    if (_showChart) ...[
                      SizedBox(
                        height: 250,
                        child: _buildPieChart(portfolio),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _buildRecommendationsSection(portfolio),
                    const SizedBox(height: 24),
                    Text(
                      'Состав портфеля',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...portfolio.entries.map((entry) {
                      return _buildAssetTile(entry.key, entry.value);
                    }).toList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.outfit(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Сумма для инвестиций',
                        hintText: 'Например: 10000',
                        prefixText: '\$ ',
                        labelStyle: GoogleFonts.outfit(color: primaryColor),
                        hintStyle: GoogleFonts.outfit(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isBuying ? null : _buyPortfolio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isBuying
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              'Подключить и распределить',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Future<void> _buyPortfolio() async {
    setState(() {
      _isBuying = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Пользователь не найден.");
      }

      final String budgetText = _budgetController.text.trim().replaceAll(',', '.');
      if (budgetText.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пожалуйста, введите сумму бюджета.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isBuying = false);
        return;
      }

      final double? totalInvestment = double.tryParse(budgetText);
      if (totalInvestment == null || totalInvestment <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пожалуйста, введите корректную сумму.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isBuying = false);
        return;
      }

      final portfolio = _generatePortfolio();

      final Map<String, double> purchasePrices = {};
      portfolio.forEach((key, value) {
        if (_mockAssetPrices.containsKey(key)) {
          purchasePrices[key] = _mockAssetPrices[key]!;
        }
      });

      // Save portfolio to Firestore
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userRef.update({
        'purchased_portfolio': portfolio,
        'total_investment_value': totalInvestment,
        'purchase_prices': purchasePrices,
        'onboarding_completed': true, // Mark onboarding as complete
      });

      // Simulate network delay for API calls
      // TODO: Implement real API calls to 3Commas or Fatty.io
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Активы успешно распределены!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SetPasscodeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при покупке: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBuying = false;
        });
      }
    }
  }

  Widget _buildPieChart(Map<String, Map<String, dynamic>> portfolio) {
    final List<Color> chartColors = [
      Colors.blue.shade400,
      Colors.red.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
    ];

    int colorIndex = 0;
    final List<PieChartSectionData> sections = portfolio.entries.map((entry) {
      final double percentage = entry.value['percentage'];
      final color = chartColors[colorIndex % chartColors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: percentage,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 80,
        titleStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

    Widget _buildRecommendationsSection(Map<String, Map<String, dynamic>> portfolio) {
    int riskChoice = _answers!['risk_appetite_assets'] ?? 2;
    String profile, recommendation, horizon;
    IconData profileIcon, recommendationIcon, horizonIcon;

    switch (riskChoice) {
      case 0: // Aggressive
        profile = 'Агрессивный';
                final memcoinsList = portfolio['Memcoins']?['selected_coins'] as List<String>? ?? [];
        recommendation = 'Основной фокус на высокорискованных активах (${memcoinsList.join(', ')}) для максимальной доходности. Небольшая часть в BTC и ETH для баланса.';
        horizon = 'Краткосрочные и среднесрочные спекуляции для быстрого роста капитала.';
        profileIcon = FontAwesomeIcons.bolt;
        recommendationIcon = FontAwesomeIcons.arrowTrendUp;
        horizonIcon = FontAwesomeIcons.hourglassHalf;
        break;
      case 1: // Moderate
        profile = 'Умеренный';
        recommendation = 'Сбалансированный подход: 60-70% в фундаментальных активах (BTC, ETH) и 30-40% в перспективных альткоинах с умеренным риском.';
        horizon = 'Среднесрочный горизонт с фокусом на стабильном росте и умеренной волатильности.';
        profileIcon = FontAwesomeIcons.balanceScale;
        recommendationIcon = FontAwesomeIcons.chartLine;
        horizonIcon = FontAwesomeIcons.calendarCheck;
        break;
      default: // Conservative
        profile = 'Консервативный';
        recommendation = 'Ваш главный приоритет — безопасность капитала. Рекомендуется сосредоточить 80-90% портфеля в фундаментальных активах, таких как Bitcoin и Ethereum.';
        horizon = 'Ваш долгосрочный горизонт позволяет игнорировать краткосрочную волатильность и фокусироваться на фундаментальном росте активов.';
        profileIcon = FontAwesomeIcons.shieldHalved;
        recommendationIcon = FontAwesomeIcons.solidThumbsUp;
        horizonIcon = FontAwesomeIcons.solidHourglass;
        break;
    }

    return Column(
      children: [
        _buildInfoCard(icon: profileIcon, title: 'Ваш Профиль', text: profile),
        const SizedBox(height: 12),
        _buildInfoCard(icon: recommendationIcon, title: 'Рекомендации по активам', text: recommendation),
        const SizedBox(height: 12),
        _buildInfoCard(icon: horizonIcon, title: 'Инвестиционный горизонт', text: horizon),
      ],
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FF), // Light purple background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, color: const Color(0xFF4B39EF), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetTile(String assetSymbol, Map<String, dynamic> assetData) {
    final double percentage = assetData['percentage'];
    final String rationale = assetData['rationale'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: (_assetColors[assetSymbol] ?? Colors.grey).withOpacity(0.1),
                child: FaIcon(_assetIcons[assetSymbol] ?? FontAwesomeIcons.questionCircle, color: _assetColors[assetSymbol] ?? Colors.grey, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_assetFullNames[assetSymbol] ?? assetSymbol, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(assetSymbol, style: GoogleFonts.outfit(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4B39EF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
                    Text(
            rationale,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          if (assetSymbol == 'Memcoins' && assetData.containsKey('selected_coins'))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Включает: ${(assetData['selected_coins'] as List<String>).join(', ')}',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
