import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/pointycastle.dart';
import 'dart:convert';
import 'dart:typed_data';

class ExchangeAuthService {
  // Helper to parse PEM-encoded private key
  RSAPrivateKey _parsePrivateKey(String pem) {
    final lines = LineSplitter.split(pem)
        .where((line) => !line.startsWith('-----'))
        .join('');
    final keyBytes = base64.decode(lines);
    final asn1Parser = ASN1Parser(keyBytes);
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    ASN1OctetString privateKeyOctet;
    if (topLevelSeq.elements!.length > 2) {
      privateKeyOctet = topLevelSeq.elements![2] as ASN1OctetString;
    } else {
      privateKeyOctet = topLevelSeq.elements![1] as ASN1OctetString;
    }

    final pkParser = ASN1Parser(privateKeyOctet.octets);
    final pkSeq = pkParser.nextObject() as ASN1Sequence;

    final BigInt modulus = (pkSeq.elements![1] as ASN1Integer).integer!;
    final BigInt privateExponent = (pkSeq.elements![3] as ASN1Integer).integer!;
    final BigInt p = (pkSeq.elements![4] as ASN1Integer).integer!;
    final BigInt q = (pkSeq.elements![5] as ASN1Integer).integer!;

    return RSAPrivateKey(modulus, privateExponent, p, q);
  }

  // Helper to create a signature for Bybit
  String _createBybitSignature(String message, String privateKeyPem) {
    final privateKey = _parsePrivateKey(privateKeyPem);
    final signer = Signer('SHA-256/RSA');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    final signature = signer.generateSignature(Uint8List.fromList(utf8.encode(message))) as RSASignature;
    return base64.encode(signature.bytes);
  }

  final _secureStorage = const FlutterSecureStorage();

  // Configuration for each exchange's token endpoint
  final Map<String, Map<String, String>> _exchangeConfigs = {
    'bybit': {
      'tokenUrl': 'https://api.bybit.com/v5/oauth/token',
    },
    'mexc': {
      'tokenUrl': 'https://www.mexc.com/open/api/v2/oauth/token',
    },
    'gate.io': {
      'tokenUrl': 'https://api.gateio.ws/api/v4/oauth/token',
    },
    'kucoin': {
      'tokenUrl': 'https://api.kucoin.com/oauth/token',
    },
    'htx': {
      'tokenUrl': 'https://api.huobi.pro/oauth/token',
    },
    'bitget': {
      'tokenUrl': 'https://api.bitget.com/api/v2/oauth/token',
    },
  };

  Future<Map<String, dynamic>?> exchangeCodeForToken(
      String platformName, String code) async {
    final config = _exchangeConfigs[platformName.toLowerCase()];
    if (config == null) {
      print('Unsupported exchange: $platformName');
      return null;
    }

    final clientId = dotenv.env['${platformName.toUpperCase()}_API_KEY'];
    final clientSecret = dotenv.env['${platformName.toUpperCase()}_API_SECRET'];

    if (clientId == null) {
      print('API Key for $platformName not found in .env file');
      return null;
    }

    final body = {
      'grant_type': 'authorization_code',
      'code': code,
      'client_id': clientId,
      'redirect_uri': 'algobait://oauth/callback',
    };

    if (clientSecret != null) {
      body['client_secret'] = clientSecret;
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (platformName.toLowerCase() == 'bybit') {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final brokerPrivateKey = dotenv.env['BYBIT_BROKER_PRIVATE_KEY'];
      if (brokerPrivateKey == null) {
        print('Bybit Broker Private Key not found in .env');
        return null;
      }

      final signaturePayload = timestamp + clientId + code;
      final signature = _createBybitSignature(signaturePayload, brokerPrivateKey);

      headers.addAll({
        'X-BAPI-API-KEY': clientId,
        'X-BAPI-TIMESTAMP': timestamp,
        'X-BAPI-SIGN': signature,
        'X-BAPI-RECV-WINDOW': '10000',
      });
    }

    try {
      final response = await http.post(
        Uri.parse(config['tokenUrl']!),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Successfully exchanged code for token: $data');

        await _secureStorage.write(
            key: '${platformName}_access_token', value: data['access_token']);
        if (data['refresh_token'] != null) {
          await _secureStorage.write(
              key: '${platformName}_refresh_token', value: data['refresh_token']);
        }

        return data;
      } else {
        print('Failed to exchange code for token: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error exchanging code for token: $e');
      return null;
    }
  }
}
