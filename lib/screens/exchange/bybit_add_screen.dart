import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algobait/services/exchange_auth_service.dart';
import 'exchange_webview_screen.dart';
import 'package:algobait/screens/platform/platform_connect_screen.dart';

class BybitAddScreen extends StatefulWidget {
  final String platformName;

  const BybitAddScreen({Key? key, required this.platformName}) : super(key: key);

  @override
  State<BybitAddScreen> createState() => _BybitAddScreenState();
}

class _BybitAddScreenState extends State<BybitAddScreen> {
  final ExchangeAuthService _authService = ExchangeAuthService();
  bool _isLoading = false;
  void _startConnectionProcess() async {
    final platform = widget.platformName.toLowerCase();
    final String? clientId = dotenv.env['${platform.toUpperCase()}_API_KEY'];
    const String redirectUri = 'https://algobait.com/oauth/callback';
    
    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: Ключ API для $platform не настроен в .env файле.')),
      );
      return;
    }

    // NOTE: These URLs are examples and must be verified with official documentation.
    final Map<String, String> authUrlTemplates = {
      'bybit': 'https://www.bybit.com/v5/oauth/authorize?client_id={CLIENT_ID}&response_type=code&redirect_uri={REDIRECT_URI}&scope=read_write',
      'mexc': 'https://www.mexc.com/open/api/v2/oauth/authorize?client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}&response_type=code&scope=spot:read,spot:write',
      'gate.io': 'https://www.gate.io/oauth2/authorize?client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}&response_type=code&scope=perpetual_account_read,spot_account_read',
      'kucoin': 'https://www.kucoin.com/oauth/authorize?client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}&response_type=code&scope=read_write',
      'htx': 'https://www.htx.com/oauth/authorize?client_id={CLIENT_ID}&response_type=code&redirect_uri={REDIRECT_URI}&scope=read_write',
      'bitget': 'https://www.bitget.com/oauth/authorize?client_id={CLIENT_ID}&response_type=code&redirect_uri={REDIRECT_URI}&scope=read_write',
    };

    final urlTemplate = authUrlTemplates[platform];

    if (urlTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Процесс подключения для $platform еще не поддерживается.')),
      );
      return;
    }

    final authUrl = urlTemplate
        .replaceAll('{CLIENT_ID}', clientId)
        .replaceAll('{REDIRECT_URI}', redirectUri);

    print('Navigating to: $authUrl');

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExchangeWebViewScreen(initialUrl: authUrl),
      ),
    );

    if (result != null && result is String) {
      final String code = result;
      print('Received authorization code: $code');

      setState(() {
        _isLoading = true;
      });

      final bool success = await _authService.exchangeCodeForToken(widget.platformName, code);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String fieldName = '${widget.platformName.toLowerCase().replaceAll(' ', '_').replaceAll('.io', 'io')}_connected';
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            fieldName: true,
          }, SetOptions(merge: true));
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.platformName} успешно подключен!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const PlatformConnectScreen()),
            (route) => route.isFirst,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Не удалось подключить ${widget.platformName}. Попробуйте снова.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print('Connection process was cancelled or failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4B39EF);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Подключить ${widget.platformName}',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(Icons.sync_lock_rounded, color: primaryColor, size: 80),
            const SizedBox(height: 24),
            Text(
              'Безопасное подключение',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Вы будете перенаправлены на официальную страницу ${widget.platformName} для входа в свой аккаунт и предоставления нашему приложению необходимых разрешений. Мы не получаем доступ к вашим логину и паролю.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const Spacer(),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _startConnectionProcess,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Подключить через ${widget.platformName}',
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
    );
  }
}
