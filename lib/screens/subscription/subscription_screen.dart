import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../exchange/exchange_connect_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Plan { basic, pro, premium }

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Plan? _selectedPlan = Plan.pro; // Default selection

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF4B39EF);

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: Stack(
        children: [
          // Background Gradient Chart Area
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.60,
            width: double.infinity,
            child: CustomPaint(
              painter: ChartPainter(color: primaryColor),
            ),
          ),

          // Content Area
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeatureRow(FontAwesomeIcons.penToSquare, 'Создание индивидуальной торговой стратегии'),
                    const SizedBox(height: 16),
                    _buildFeatureRow(FontAwesomeIcons.magnifyingGlass, 'Подбор финансового инструмента'),
                    const SizedBox(height: 16),
                    _buildFeatureRow(FontAwesomeIcons.briefcase, 'Создание инвестиционного портфеля'),
                    const SizedBox(height: 16),
                    _buildFeatureRow(FontAwesomeIcons.rocket, 'Создание индивидуального торгового робота'),
                    const SizedBox(height: 32),

                    _buildSubscriptionOption(
                      plan: Plan.basic,
                      title: 'Ежемесячная подписка',
                      price: '14,50\$/месяц',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    _buildSubscriptionOption(
                      plan: Plan.pro,
                      title: 'Ежегодная подписка',
                      price: '155,00\$/год',
                      primaryColor: primaryColor,
                      isRecommended: true,
                      discount: '-10,9%',
                    ),
                    const SizedBox(height: 16),
                    _buildSubscriptionOption(
                      plan: Plan.premium,
                      title: 'Пожизненная подписка',
                      price: '399,00\$',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _selectedPlan == null
                          ? null
                          : () async {
                              // Save the next route to local storage
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('last_route', '/exchange-connect');

                              // TODO: handle purchase flow
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Тариф ${_selectedPlan!.name.toUpperCase()} выбран')),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ExchangeConnectScreen()),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4B39EF), size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionOption({
    required Plan plan,
    required String title,
    required String price,
    required Color primaryColor,
    bool isRecommended = false,
    String? discount,
  }) {
    final bool isSelected = _selectedPlan == plan;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: GoogleFonts.readexPro(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isRecommended && discount != null)
            Positioned(
              top: -12,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFAA9CFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  discount,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final Color color;

  ChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.5), color.withOpacity(0.05)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.cubicTo(size.width * 0.1, size.height * 0.1, size.width * 0.2, size.height * 0.5, size.width * 0.3, size.height * 0.3);
    path.cubicTo(size.width * 0.4, size.height * 0.1, size.width * 0.5, size.height * 0.4, size.width * 0.6, size.height * 0.2);
    path.cubicTo(size.width * 0.7, size.height * 0.0, size.width * 0.8, size.height * 0.3, size.width * 0.9, size.height * 0.1);
    path.cubicTo(size.width * 0.95, size.height * 0.0, size.width, size.height * 0.2, size.width, size.height * 0.2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    linePath.moveTo(0, size.height * 0.3);
    linePath.cubicTo(size.width * 0.1, size.height * 0.1, size.width * 0.2, size.height * 0.5, size.width * 0.3, size.height * 0.3);
    linePath.cubicTo(size.width * 0.4, size.height * 0.1, size.width * 0.5, size.height * 0.4, size.width * 0.6, size.height * 0.2);
    linePath.cubicTo(size.width * 0.7, size.height * 0.0, size.width * 0.8, size.height * 0.3, size.width * 0.9, size.height * 0.1);
    linePath.cubicTo(size.width * 0.95, size.height * 0.0, size.width, size.height * 0.2, size.width, size.height * 0.2);

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
