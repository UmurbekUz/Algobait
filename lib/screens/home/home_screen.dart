import 'package:algobait/screens/auth/auth_screen.dart';
import 'package:algobait/screens/profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, Color> assetColors = {
    'BTC': Colors.orange,
    'ETH': const Color(0xFF627EEA),
    'BNB': Colors.yellow.shade700,
    'USDT': Colors.green,
    'SOL': Colors.purpleAccent,
  };
  late PageController _pageController;
  bool _showLineChart = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Общая стоимость активов',
              style: GoogleFonts.outfit(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$7,630',
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: const Color(0xFF4B39EF).withOpacity(0.1),
              child: const Icon(
                Icons.person,
                color: Color(0xFF4B39EF),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  '2.54% с прошлой недели',
                  style: GoogleFonts.outfit(
                    color: Colors.green,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Мой портфель',
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 280, // Gave a fixed height to the container
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4B39EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _showLineChart = index == 0;
                  });
                },
                children: [
                  _buildLineChartCardContent(),
                  _buildPieChartCardContent(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ваши активы',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildToggleChip('Баланс', _showLineChart, () {
                        _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }),
                      _buildToggleChip('Прибыль', !_showLineChart, () {
                         _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            _buildAssetItem(FontAwesomeIcons.bitcoin, 'Bitcoin', 'BTC', '\$1090.00'),
            _buildAssetItem(FontAwesomeIcons.ethereum, 'Ethereum', 'ETH', '\$214.80'),
            _buildAssetItem(FontAwesomeIcons.dollarSign, 'Solana', 'SOL', '\$21.80'),
          ],
        ),
      ),
    );
  }

  // Extracted card content to separate methods for clarity
  Column _buildLineChartCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Баланс', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 16)),
        Text('\$7,630', style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(child: _buildLineChart()),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['24H', '7D', '3M', '1Y', 'ALL']
              .map((label) => Text(label, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7))))
              .toList(),
        ),
      ],
    );
  }

  Column _buildPieChartCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Активы', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 16)),
        Text('\$7,630', style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(child: _buildPieChart()),
        const SizedBox(height: 10),
         Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(Colors.blue, '25% BTC'),
              _buildLegendItem(Colors.purple, '18% ETH'),
              _buildLegendItem(Colors.lightBlue, '12% SOL'),
            ],
          ),
      ],
    );
  }

  Widget _buildToggleChip(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4B39EF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAssetItem(IconData icon, String name, String symbol, String value) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          child: FaIcon(icon, color: Colors.black),
        ),
        title: Text(name, style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
        subtitle: Text(symbol, style: GoogleFonts.outfit(color: Colors.grey.shade600)),
        trailing: Text(value, style: GoogleFonts.outfit(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7))),
      ],
    );
  }

  LineChart _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5), FlSpot(5, 3.5), FlSpot(6, 4)],
            isCurved: true,
            color: Colors.white,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ],
      ),
    );
  }

  PieChart _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(color: Colors.blue.shade400, value: 25, title: '', radius: 25),
          PieChartSectionData(color: Colors.purple.shade400, value: 18, title: '', radius: 25),
          PieChartSectionData(color: Colors.lightBlue.shade300, value: 12, title: '', radius: 25),
          PieChartSectionData(color: Colors.grey.withOpacity(0.5), value: 45, title: '', radius: 25),
        ],
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }
}
