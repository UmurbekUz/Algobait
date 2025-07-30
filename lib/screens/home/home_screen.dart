import 'package:algobait/screens/profile/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:algobait/services/currency_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _portfolioData;
  Map<String, dynamic>? _purchasePrices;
  double _totalValue = 0.0;
  int _selectedCardIndex = 0;
  int _selectedTimeIndex = 4; // Default to 'ALL'
  int _selectedBalanceProfitIndex = 0; // 0 for Balance, 1 for Profit
  late PageController _pageController;
  double _totalProfitLoss = 0.0;
  Map<String, double> _assetProfitLoss = {};
  String? _photoURL;

  static const List<String> _allMemecoins = [
    'DOGE', 'SHIB', 'PEPE', 'WIF', 'BONK', 'FLOKI', 'BOME', 'MEME', 'BABYDOGE',
    'MOG', 'COQ', 'TURBO', 'POPCAT', 'MYRO', 'SLERF', 'TRUMP', 'PORK',
    'WEN', 'ZYN', 'PONKE', 'BOBO', 'PEPECOIN', 'KISHU', 'SAMO', 'HOGE',
    'MONA', 'BAN', 'CUMMIES', 'PIT', 'ELON', 'LEASH', 'AKITA', 'SAITAMA',
    'VOLT', 'LUFFY', 'KUMA', 'PULI', 'MARVIN', 'CAT', 'TSUKA', 'CULT',
    'GM', 'VINU', 'SHIK', 'YOOSHI', 'QUACK', 'PIG', 'FEG', 'SANSHU', 'HINA'
  ];

  // Mock data, as in design
  static  // Current asset prices (simulating market changes)
  final Map<String, double> _currentAssetPrices = {
    'BTC': 52500.0, // Profit
    'ETH': 2950.0,  // Loss
    'SOL': 180.0,   // Profit
    'Memcoins': 0.0015, // Profit
  };
  static const Map<String, String> _assetFullNames = {
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'SOL': 'Solana',
    'Memcoins': 'Memcoins',
  };
  final Map<String, Color> assetColors = {
    'BTC': Colors.orange,
    'ETH': const Color(0xFF627EEA),
    'SOL': Colors.purpleAccent,
    'Memcoins': Colors.teal,
  };
  final Map<String, IconData> assetIcons = {
    'BTC': FontAwesomeIcons.bitcoin,
    'ETH': FontAwesomeIcons.ethereum,
    'SOL': FontAwesomeIcons.solarPanel,
    'Memcoins': FontAwesomeIcons.rocket,
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchPortfolioData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double _parsePrice(dynamic price) {
    if (price is num) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
  }

  void _calculateProfitLoss() {
    if (_portfolioData == null || _purchasePrices == null || _totalValue == 0) {
      if (mounted) {
        setState(() {
          _assetProfitLoss = {};
          _totalProfitLoss = 0.0;
        });
      }
      return;
    }

    double totalCurrentValue = 0;
    Map<String, double> assetProfitLoss = {};

    _portfolioData!.forEach((asset, data) {
      final double percentage = (data['percentage'] ?? 0.0).toDouble();
      final bool isMemcoin = _allMemecoins.contains(asset);

      // Get purchase price safely
      dynamic rawPurchasePrice = _purchasePrices![asset];
      if (rawPurchasePrice == null && isMemcoin) {
        rawPurchasePrice = _purchasePrices!['Memcoins'];
      }
      final double purchasePrice = _parsePrice(rawPurchasePrice);

      // Get current price safely
      double? currentPrice = _currentAssetPrices[asset];
      if (currentPrice == null && isMemcoin) {
        currentPrice = _currentAssetPrices['Memcoins'];
      }
      final double finalCurrentPrice = currentPrice ?? 0.0;

      if (purchasePrice > 0) {
        double investedAmount = _totalValue * (percentage / 100);
        double quantity = investedAmount / purchasePrice;
        double currentValue = quantity * finalCurrentPrice;
        double profitLoss = currentValue - investedAmount;

        assetProfitLoss[asset] = profitLoss;
        totalCurrentValue += currentValue;
      } else {
        assetProfitLoss[asset] = 0.0;
      }
    });

    if (mounted) {
      setState(() {
        _totalProfitLoss = totalCurrentValue - _totalValue;
        _assetProfitLoss = assetProfitLoss;
      });
    }
  }

  Future<void> _fetchPortfolioData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!doc.exists || doc.data() == null || !doc.data()!.containsKey('purchased_portfolio')) {
        if (mounted) setState(() {
          _isLoading = false;
          _portfolioData = null;
        });
        return;
      }

      final data = doc.data()!;
      final rawPortfolio = data['purchased_portfolio'];
      final rawPrices = data['purchase_prices'];
      final rawTotalValue = data['total_investment_value'];

      if (rawPortfolio is! Map || rawPrices is! Map || rawTotalValue == null) {
        if (mounted) setState(() { _isLoading = false; _portfolioData = null; });
        return;
      }

      Map<String, dynamic> portfolioData = Map<String, dynamic>.from(rawPortfolio);
      Map<String, dynamic> purchasePrices = Map<String, dynamic>.from(rawPrices);
      double totalValue = _parsePrice(rawTotalValue);

      if (portfolioData.containsKey('Memcoins')) {
        final memcoinsData = portfolioData['Memcoins'];
        if (memcoinsData is Map<String, dynamic> && memcoinsData['memcoins'] is List) {
          final List<dynamic> memcoinList = memcoinsData['memcoins'];
          final double memcoinPercentage = _parsePrice(memcoinsData['percentage']);

          if (memcoinPercentage > 0 && memcoinList.isNotEmpty) {
            final double individualPercentage = memcoinPercentage / memcoinList.length;
            for (var coin in memcoinList) {
              if (coin is String) {
                portfolioData[coin] = {'percentage': individualPercentage};
              }
            }
            portfolioData.remove('Memcoins');
          }
        }
      }

      if (mounted) {
        setState(() {
          _photoURL = user.photoURL;
          _portfolioData = portfolioData;
          _totalValue = totalValue;
          _purchasePrices = purchasePrices;
          _isLoading = false;
        });
        _calculateProfitLoss();
      }

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch portfolio: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyService>(
      builder: (context, currencyService, child) {
        return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isLoading
            ? const Text('Загрузка...')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedBalanceProfitIndex == 0
                        ? '+2.5% сегодня' // Placeholder
                        : '${(_totalProfitLoss / _totalValue * 100).toStringAsFixed(2)}%',
                    style: GoogleFonts.outfit(
                        color: _totalProfitLoss >= 0 ? Colors.green : Colors.red,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedBalanceProfitIndex == 0
                        ? CurrencyService().formatCurrency(_totalValue)
                        : '${_totalProfitLoss >= 0 ? '+' : ''}${CurrencyService().formatCurrency(_totalProfitLoss)}',
                    style: GoogleFonts.outfit(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              backgroundImage: _photoURL != null ? NetworkImage(_photoURL!) : null,
              child: _photoURL == null
                  ? Icon(
                      Icons.person,
                      color: Colors.grey.shade600,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _portfolioData == null
              ? Center(
                  child: Text('Портфель еще не создан.', style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text('2.54% с прошлой недели', style: GoogleFonts.outfit(color: Colors.green, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Мой портфель', style: GoogleFonts.outfit(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: PageView(
                          controller: _pageController,
                          children: [
                            _buildPurpleCard(_buildLineChartCardContent()),
                            _buildPurpleCard(_buildPieChartCardContent()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text('Ваши активы', style: GoogleFonts.outfit(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          _buildBalanceProfitToggle(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Криптовалюта', style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 16)),
                      const SizedBox(height: 8),
                      ..._buildAssetList(),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildPurpleCard(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4), // For shadow effect if needed
      decoration: BoxDecoration(
        color: const Color(0xFF4B39EF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLineChartCardContent() {
    final timeChips = ['24H', '7D', '3M', '1Y', 'ALL'];
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Баланс', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 16)),
          const SizedBox(height: 4),
          Text(CurrencyService().formatCurrency(_totalValue), style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          Expanded(child: _buildLineChart()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(timeChips.length, (index) {
              return _buildTimeToggleChip(timeChips[index], _selectedTimeIndex == index, () {
                setState(() {
                  _selectedTimeIndex = index;
                });
              });
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCardContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _buildPieChart()),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _portfolioData!.entries.map((entry) {
              final assetName = entry.key;
              final percentage = entry.value['percentage'];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildLegendItem(assetColors[assetName] ?? Colors.grey, '${percentage.toStringAsFixed(0)}% $assetName'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeToggleChip(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: GoogleFonts.outfit(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildBalanceProfitToggle() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleChip('Баланс', _selectedBalanceProfitIndex == 0, () => setState(() => _selectedBalanceProfitIndex = 0)),
          _buildToggleChip('Прибыль', _selectedBalanceProfitIndex == 1, () => setState(() => _selectedBalanceProfitIndex = 1)),
        ],
      ),
    );
  }

  Widget _buildToggleChip(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4B39EF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, style: GoogleFonts.outfit(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9))),
      ],
    );
  }

  List<Widget> _buildAssetList() {
    if (_portfolioData == null) return [];

    return _portfolioData!.entries.map((entry) {
      final assetSymbol = entry.key;
      final assetData = entry.value;
      final double percentage = (assetData['percentage'] ?? 0.0).toDouble();
      final double balanceValue = _totalValue * (percentage / 100);
      final double profitLossValue = _assetProfitLoss[assetSymbol] ?? 0.0;

      final bool isProfit = profitLossValue >= 0;
      final bool isMemcoin = _allMemecoins.contains(assetSymbol);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (assetColors[assetSymbol] ?? (isMemcoin ? assetColors['Memcoins'] : Colors.grey))!.withOpacity(0.1),
              child: FaIcon(assetIcons[assetSymbol] ?? (isMemcoin ? assetIcons['Memcoins'] : FontAwesomeIcons.questionCircle), color: assetColors[assetSymbol] ?? (isMemcoin ? assetColors['Memcoins'] : Colors.grey)),
            ),
            title: Text(_assetFullNames[assetSymbol] ?? assetSymbol, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text(isMemcoin ? 'Memcoin' : assetSymbol, style: GoogleFonts.outfit()),
            trailing: Text(
              _selectedBalanceProfitIndex == 0
                  ? CurrencyService().formatCurrency(balanceValue)
                  : '${isProfit ? '+' : ''}${CurrencyService().formatCurrency(profitLossValue)}',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _selectedBalanceProfitIndex == 0
                    ? Colors.black
                    : isProfit
                        ? Colors.green
                        : Colors.red,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<FlSpot> _getChartData(int timeIndex) {
    final random = Random();
    List<FlSpot> spots = [];
    int points;

    switch (timeIndex) {
      case 0: // 24H
        points = 24;
        break;
      case 1: // 7D
        points = 7;
        break;
      case 2: // 3M
        points = 30;
        break;
      case 3: // 1Y
        points = 12;
        break;
      case 4: // ALL
      default:
        points = 24;
        break;
    }

    double startValue = _totalValue > 0 ? _totalValue : 10000; 
    double lastValue = startValue;
    for (int i = 0; i < points; i++) {
      double fluctuation = (random.nextDouble() - 0.5) * (lastValue * 0.05);
      lastValue += fluctuation;
      spots.add(FlSpot(i.toDouble(), lastValue.clamp(0, double.infinity)));
    }
    return spots;
  }

  LineChart _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _getChartData(_selectedTimeIndex),
            isCurved: true,
            color: Colors.white,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  PieChart _buildPieChart() {
    if (_portfolioData == null) return PieChart(PieChartData(sections: []));

    return PieChart(
      PieChartData(
        sections: _portfolioData!.entries.map((entry) {
          final assetName = entry.key;
          final percentage = entry.value['percentage'];
          final isMemcoin = _allMemecoins.contains(assetName);
          return PieChartSectionData(
            color: assetColors[assetName] ?? (isMemcoin ? assetColors['Memcoins'] : Colors.grey),
            value: percentage,
            title: '',
            radius: 50,
          );
        }).toList(),
        centerSpaceRadius: 60,
        sectionsSpace: 4,
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

