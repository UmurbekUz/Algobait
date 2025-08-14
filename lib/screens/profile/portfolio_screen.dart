import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:algobait/services/currency_service.dart';
import 'package:provider/provider.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _portfolioData = {};
  Map<String, dynamic> _purchasePrices = {};
  double _totalValue = 0.0;
  Map<String, double> _assetProfitLoss = {};
  String? _riskProfile;

  // Mock data for asset details
  final Map<String, double> _currentAssetPrices = {
    'BTC': 52500.0, 'ETH': 2950.0, 'SOL': 180.0, 'Memcoins': 0.0015,
  };
  final Map<String, String> _assetFullNames = {
    'BTC': 'Bitcoin', 'ETH': 'Ethereum', 'SOL': 'Solana', 'Memcoins': 'Memcoins',
  };
  final Map<String, Color> assetColors = {
    'BTC': Colors.orange, 'ETH': const Color(0xFF627EEA), 'SOL': Colors.purpleAccent, 'Memcoins': Colors.teal,
  };
  final Map<String, IconData> assetIcons = {
    'BTC': FontAwesomeIcons.bitcoin, 'ETH': FontAwesomeIcons.ethereum, 'SOL': FontAwesomeIcons.solarPanel, 'Memcoins': FontAwesomeIcons.rocket,
  };

  @override
  void initState() {
    super.initState();
    _fetchPortfolioData();
  }

  Future<void> _fetchPortfolioData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Пользователь не найден");

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (mounted && doc.exists) {
        final data = doc.data()!;

        // Safely parse data from Firestore
        final riskProfile = data['risk_profile'] as String?;
        final totalValue = (data['total_investment_value'] as num? ?? 0.0).toDouble();
        final portfolioData = data.containsKey('purchased_portfolio') ? Map<String, dynamic>.from(data['purchased_portfolio'] as Map) : <String, dynamic>{};
        final purchasePrices = data.containsKey('purchase_prices') ? Map<String, dynamic>.from(data['purchase_prices'] as Map) : <String, dynamic>{};
        
        setState(() {
          _riskProfile = riskProfile;
          _totalValue = totalValue;
          _portfolioData = portfolioData;
          _purchasePrices = purchasePrices;
          _calculateProfitLoss();
        });
      } else {
         setState(() {
          _portfolioData = {}; // Ensure portfolio is cleared if no data
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить данные: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calculateProfitLoss() {
    if (_portfolioData.isEmpty || _purchasePrices.isEmpty || _totalValue == 0) return;

    Map<String, double> newProfitLoss = {};
    _portfolioData.forEach((asset, data) {
      final double percentage = (data['percentage'] as num? ?? 0.0).toDouble();
      final double purchasePrice = (_purchasePrices[asset] as num? ?? 0.0).toDouble();
      final double currentPrice = _currentAssetPrices[asset] ?? 0.0;

      if (purchasePrice > 0) {
        double investedAmount = _totalValue * (percentage / 100);
        double quantity = investedAmount / purchasePrice;
        double currentValue = quantity * currentPrice;
        newProfitLoss[asset] = currentValue - investedAmount;
      }
    });

    setState(() {
      _assetProfitLoss = newProfitLoss;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyService>(
      builder: (context, currencyService, child) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Инвестиционный Портфель', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _buildBody(),
    );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4B39EF)));
    }
    if (_error != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center,)));
    }

    return RefreshIndicator(
      onRefresh: _fetchPortfolioData,
      color: const Color(0xFF4B39EF),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (_riskProfile != null && _riskProfile!.isNotEmpty) ...[
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildRecommendationsSection(),
            const SizedBox(height: 16),
            _buildInvestmentHorizonCard(),
            const SizedBox(height: 24),
          ],
          if (_portfolioData.isNotEmpty) ...[
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: const Color(0xFFF7F7FF),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Общая стоимость портфеля',
                        style: GoogleFonts.outfit(
                            fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Text(CurrencyService().formatCurrency(_totalValue),
                        style: GoogleFonts.outfit(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Активы в портфеле',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._portfolioData.entries.map((entry) {
              return _buildAssetTile(entry.key, entry.value);
            }).toList(),
          ] else if (_riskProfile != null && _riskProfile!.isNotEmpty) ...[
             _buildEmptyPortfolioView()
          ]
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required Color iconColor, required String title, required String body}) {
      return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFF7F7FF),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FaIcon(icon, color: iconColor, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(body, style: GoogleFonts.outfit(fontSize: 14, color: Colors.black.withOpacity(0.7), height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return _buildInfoCard(
      icon: FontAwesomeIcons.shieldHalved,
      iconColor: const Color(0xFF4B39EF),
      title: 'Ваш Профиль',
      body: _riskProfile ?? 'Не определен',
    );
  }

  Widget _buildRecommendationsSection() {
    return _buildInfoCard(
      icon: FontAwesomeIcons.solidLightbulb,
      iconColor: Colors.amber.shade700,
      title: 'Рекомендации по активам',
      body: 'Ваш главный приоритет — безопасность капитала. Рекомендуется сосредоточить 80-90% портфеля в фундаментальных активах, таких как Bitcoin и Ethereum. Небольшую часть (10-20%) можно направить на менее рискованные альткоины с уже устоявшейся репутацией.',
    );
  }

  Widget _buildInvestmentHorizonCard() {
    return _buildInfoCard(
      icon: FontAwesomeIcons.hourglassHalf,
      iconColor: const Color(0xFF4B39EF),
      title: 'Инвестиционный горизонт',
      body: 'Ваш долгосрочный горизонт позволяет игнорировать краткосрочную волатильность и фокусироваться на фундаментальном росте активов.',
    );
  }

  Widget _buildEmptyPortfolioView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(FontAwesomeIcons.folderOpen, size: 40, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Ваш портфель пока пуст', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Как только вы распределите активы, они появятся здесь.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetTile(String assetSymbol, Map<String, dynamic> assetData) {
    final double percentage = (assetData['percentage'] as num? ?? 0.0).toDouble();
    final String rationale = assetData['rationale'] as String? ?? 'Обоснование не найдено.';
    final double balanceValue = _totalValue * (percentage / 100);
    final double profitLossValue = _assetProfitLoss[assetSymbol] ?? 0.0;
    final bool isProfit = profitLossValue >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: (assetColors[assetSymbol] ?? Colors.grey).withOpacity(0.1),
                  child: FaIcon(assetIcons[assetSymbol] ?? FontAwesomeIcons.questionCircle, color: assetColors[assetSymbol] ?? Colors.grey, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(_assetFullNames[assetSymbol] ?? assetSymbol, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18))),
                Text('${percentage.toStringAsFixed(0)}%', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF4B39EF))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Баланс', style: GoogleFonts.outfit(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(CurrencyService().formatCurrency(balanceValue), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('P/L', style: GoogleFonts.outfit(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text('${isProfit ? "+" : ""}${CurrencyService().formatCurrency(profitLossValue)}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: isProfit ? Colors.green.shade600 : Colors.red.shade600)),
                ]),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),
            Text('Обоснование выбора:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(rationale, style: GoogleFonts.outfit(fontSize: 14, color: Colors.black.withOpacity(0.7), height: 1.4)),
          ],
        ),
      ),
    );
  }
}
