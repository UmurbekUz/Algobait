import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    // Sample data
    const double portfolioValue = 12450.78;
    const double portfolioChange = 352.25;
    const double portfolioChangePercent = 2.91;

    final List<Map<String, dynamic>> assets = [
      {'icon': FontAwesomeIcons.bitcoin, 'name': 'Bitcoin', 'amount': '0.5 BTC', 'value': 8500.00, 'change': 5.2},
      {'icon': FontAwesomeIcons.ethereum, 'name': 'Ethereum', 'amount': '2 ETH', 'value': 3200.00, 'change': -1.8},
      {'icon': Icons.show_chart, 'name': 'S&P 500 ETF', 'amount': '10 Shares', 'value': 750.78, 'change': 2.1},
    ];

    final List<Map<String, dynamic>> recommendations = [
      {'name': 'Solana', 'reason': 'High Growth Potential'},
      {'name': 'Tech Stocks Fund', 'reason': 'Diversified Tech Exposure'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Инвестиционный Портфель',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(currencyFormat, portfolioValue, portfolioChange, portfolioChangePercent),
            const SizedBox(height: 24),
            _buildChartCard(),
            const SizedBox(height: 24),
            _buildSectionHeader('Ваши Активы'),
            const SizedBox(height: 16),
            ...assets.map((asset) => _buildAssetTile(currencyFormat, asset)).toList(),
            const SizedBox(height: 24),
            _buildSectionHeader('Рекомендации для Вас'),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => _buildRecommendationCard(rec)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(NumberFormat format, double value, double change, double changePercent) {
    final bool isPositive = change >= 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4B39EF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Общий баланс',
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            format.format(value),
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, color: isPositive ? Colors.greenAccent : Colors.redAccent, size: 18),
              const SizedBox(width: 6),
              Text(
                '${format.format(change)} (${changePercent.toStringAsFixed(2)}%)',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              Text('Today', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7)))
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Динамика портфеля', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1), FlSpot(1, 1.5), FlSpot(2, 1.4), FlSpot(3, 3.4), FlSpot(4, 2), FlSpot(5, 4), FlSpot(6, 3),
                      ],
                      isCurved: true,
                      color: const Color(0xFF4B39EF),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF4B39EF).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildAssetTile(NumberFormat format, Map<String, dynamic> asset) {
    final bool isPositive = asset['change'] >= 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4B39EF).withOpacity(0.1),
          child: FaIcon(asset['icon'], color: const Color(0xFF4B39EF), size: 20),
        ),
        title: Text(asset['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        subtitle: Text(asset['amount'], style: GoogleFonts.outfit(color: Colors.grey.shade600)),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(format.format(asset['value']), style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              '${isPositive ? '+' : ''}${asset['change']}%',
              style: GoogleFonts.outfit(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9), // Light green
          child: Icon(Icons.lightbulb_outline, color: Colors.green),
        ),
        title: Text(recommendation['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        subtitle: Text(recommendation['reason'], style: GoogleFonts.outfit(color: Colors.grey.shade600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
