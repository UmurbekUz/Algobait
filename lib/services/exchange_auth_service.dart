import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ExchangeAuthService {
  final _secureStorage = const FlutterSecureStorage();

  // NOTE: These URLs and parameter names are examples and MUST be verified with official docs.
  final Map<String, String> _tokenUrlMap = {
    'bybit': 'https://api.bybit.com/v5/oauth/token',
    'mexc': 'https://www.mexc.com/open/api/v2/oauth/token',
    'gate.io': 'https://api.gateio.ws/api/v4/oauth/token',
    'kucoin': 'https://api.kucoin.com/oauth/token',
    'htx': 'https://api.htx.com/oauth/token',
  };

  Future<bool> exchangeCodeForToken(String platform, String code) async {
    final lowerCasePlatform = platform.toLowerCase();
    final tokenUrl = _tokenUrlMap[lowerCasePlatform];

    final String? clientId = dotenv.env['${lowerCasePlatform.toUpperCase()}_API_KEY'];
    // IMPORTANT: We are assuming the secret key is also in the .env file.
    final String? clientSecret = dotenv.env['${lowerCasePlatform.toUpperCase()}_SECRET_KEY'];
    const String redirectUri = 'https://algobait.com/oauth/callback';

    if (tokenUrl == null || clientId == null || clientSecret == null) {
      print('Error: Configuration for $platform is missing in .env or service file.');
      return false;
    }

    try {
      print('Exchanging code for token for platform: $platform');
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];

        if (accessToken != null) {
          // Securely store the tokens
          await _secureStorage.write(key: '${lowerCasePlatform}_access_token', value: accessToken);
          if (refreshToken != null) {
            await _secureStorage.write(key: '${lowerCasePlatform}_refresh_token', value: refreshToken);
          }
          print('$platform connection successful! Access token stored.');
          return true;
        } else {
          print('Error: access_token not found in response.');
          return false;
        }
      } else {
        print('Failed to exchange code. Server responded with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('An error occurred during token exchange: $e');
      return false;
    }
  }
}
