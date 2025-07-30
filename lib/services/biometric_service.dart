import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Check if biometric authentication is available on the device
  static Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }

  // Authenticate the user with biometrics
  static Future<bool> authenticate(String localizedReason) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep the dialog open on app switch
          biometricOnly: true, // Only allow biometrics, no device PIN
        ),
      );
    } on PlatformException catch (e) {
      print('Error during authentication: $e');
      return false;
    }
  }

  // Check if the user has enabled biometric auth in settings
  static Future<bool> isBiometricAuthEnabled() async {
    final stored = await _storage.read(key: _biometricEnabledKey);
    return stored == 'true';
  }

  // Enable or disable biometric auth in settings
  static Future<void> setBiometricAuthEnabled(bool value) async {
    await _storage.write(key: _biometricEnabledKey, value: value.toString());
  }
}
