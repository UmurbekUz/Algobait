import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algobait/services/exchange_auth_service.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:algobait/screens/platform/platform_connect_screen.dart';

class BybitAddScreen extends StatefulWidget {
  final String platformName;

  const BybitAddScreen({Key? key, required this.platformName}) : super(key: key);

  @override
  State<BybitAddScreen> createState() => _BybitAddScreenState();
}

class _BybitAddScreenState extends State<BybitAddScreen> {
  final ExchangeAuthService _authService = ExchangeAuthService();
  final _appLinks = AppLinks();
  bool _isLoading = false;
  StreamSubscription<Uri>? _linkSubscription;
  String? _oauthState;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    // Subscribe to all incoming links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (mounted) {
        _processUri(uri);
      }
    }, onError: (err) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка обработки ссылки: $err'), backgroundColor: Colors.red),
        );
      }
    });
  }

  void _processUri(Uri uri) {
    if (uri.scheme != 'algobait' || !uri.queryParameters.containsKey('code')) return;

    final returnedState = uri.queryParameters['state'];
    if (_oauthState == null || returnedState != _oauthState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка безопасности: неверный параметр state.'), backgroundColor: Colors.red),
      );
      return;
    }

    final code = uri.queryParameters['code']!;
    if (!_isLoading) { // Prevent multiple triggers
      _finishConnectionProcess(code);
    }
  }

  Future<void> _finishConnectionProcess(String code) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic>? result = await _authService.exchangeCodeForToken(widget.platformName, code);
      final bool success = result != null;

      if (!mounted) return;

      if (success) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String fieldName = '${widget.platformName.toLowerCase().replaceAll(' ', '_').replaceAll('.io', 'io')}_connected';
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            fieldName: true,
          }, SetOptions(merge: true));
        }

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
      } else {
        throw Exception('Не удалось получить токен, результат пуст.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка подключения: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  String _generateRandomString(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  void _startConnectionProcess() async {
    setState(() => _isLoading = true);
    _oauthState = _generateRandomString(32);

    final platform = widget.platformName.toLowerCase();
    final String? clientId = dotenv.env['${platform.toUpperCase().replaceAll('.IO', 'IO')}_API_KEY'];
    const String redirectUri = 'algobait://oauth/callback'; // NEW REDIRECT URI
    
    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: Ключ API для $platform не настроен в .env файле.')),
      );
      return;
    }

    // NOTE: These URLs are examples and must be verified with official documentation.
    final Map<String, String> authUrlTemplates = {
      'bybit': 'https://www.bybit.com/oauth/authorize?client_id={CLIENT_ID}&response_type=code&redirect_uri={REDIRECT_URI}&scope=read_write&force_view=true&state={STATE}',
      'mexc': 'https://www.mexc.com/open/api/v2/oauth/authorize?client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}&response_type=code&scope=spot:read,spot:write&state={STATE}',
      'gate.io': 'https://www.gate.io/oauth2/authorize?client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}&response_type=code&scope=perpetual_account_read,spot_account_read&state={STATE}',
      'kucoin': 'https://www.kucoin.com/oauth/authorize?client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}&response_type=code&scope=read_write&state={STATE}',
      'htx': 'https://www.htx.com/oauth/authorize?client_id={CLIENT_ID}&response_type=code&redirect_uri={REDIRECT_URI}&scope=read_write&state={STATE}',
      'bitget': 'https://www.bitget.com/oauth/authorize?client_id={CLIENT_ID}&response_type=code&redirect_uri={REDIRECT_URI}&scope=read_write&state={STATE}',
    };

    final urlTemplate = authUrlTemplates[platform];

    if (urlTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Процесс подключения для $platform еще не поддерживается.')),
      );
      return;
    }

    final authUrlString = urlTemplate
        .replaceAll('{CLIENT_ID}', clientId)
        .replaceAll('{REDIRECT_URI}', redirectUri)
        .replaceAll('{STATE}', _oauthState!);

    final authUri = Uri.parse(authUrlString);

    if (await canLaunchUrl(authUri)) {
      await launchUrl(authUri, mode: LaunchMode.externalApplication);
    } else {
      if(mounted) {
         setState(() => _isLoading = false);
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось открыть браузер.'), backgroundColor: Colors.red),
         );
      }
    }

    // The logic is now handled by _finishConnectionProcess via the uni_links stream.
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
