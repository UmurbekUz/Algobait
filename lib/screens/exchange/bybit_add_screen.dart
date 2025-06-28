import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../platform/platform_connect_screen.dart';
import '../questionnaire/questionnaire_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BybitAddScreen extends StatefulWidget {
  final String platformName;

  const BybitAddScreen({super.key, required this.platformName});

  @override
  State<BybitAddScreen> createState() => _BybitAddScreenState();
}

class _BybitAddScreenState extends State<BybitAddScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _apiKeyController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4B39EF);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Добавить ${widget.platformName}',
          style: GoogleFonts.lato(
            color: primaryColor,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: primaryColor,
                    border: Border.all(color: primaryColor, width: 3),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: primaryColor,
                  labelStyle: GoogleFonts.readexPro(fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.readexPro(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Быстрое подключение'),
                    Tab(text: 'API ключи'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildQuickConnectTab(primaryColor),
                  _buildApiKeysTab(primaryColor),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 15, 15),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    // If we are connecting an exchange (like Bybit), save the next step and go to platform selection
                    if (widget.platformName == 'Bybit') {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('last_route', '/platform-connect');
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PlatformConnectScreen()),
                        );
                      }
                    } else {
                      // If we are connecting a platform (like 3Commas), go to the questionnaire
                      // TODO: Implement actual connection logic here
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuestionnaireScreen()),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка: ${e.toString()}')),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Подключить',
                  style: GoogleFonts.readexPro(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickConnectTab(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TODO: Replace with actual logos
              Icon(Icons.business, size: 50, color: primaryColor),
              const SizedBox(width: 20),
              Icon(Icons.link, size: 40, color: Colors.grey[600]),
              const SizedBox(width: 20),
              Icon(Icons.shield, size: 50, color: Colors.green),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Быстрое подключение',
            style: GoogleFonts.readexPro(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Прямое соединение с биржей - самое безопасное и быстрое. Никто не сможет получить к вашим API-ключам.',
            textAlign: TextAlign.center,
            style: GoogleFonts.readexPro(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeysTab(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('Название', primaryColor),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _apiKeyController,
            decoration: _inputDecoration('API ключ', primaryColor),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _secretKeyController,
            obscureText: true,
            decoration: _inputDecoration('Secret-ключ', primaryColor),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, Color primaryColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.roboto(color: primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    );
  }
}
