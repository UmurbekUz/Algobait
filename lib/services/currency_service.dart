import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService extends ChangeNotifier {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  static const String _currencyKey = 'selected_currency';

  // Exchange rates relative to USD. In a real app, fetch this from an API.
  static const Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'EUR': 0.93, // 1 USD = 0.93 EUR
    'RUB': 91.58, // 1 USD = 91.58 RUB
  };

  static const Map<String, String> _currencySymbols = {
    'USD': 'USD',
    'EUR': '€',
    'RUB': 'RUB',
  };

  late SharedPreferences _prefs;
  String _currentCurrency = 'USD';

  String get currentCurrency => _currentCurrency;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _currentCurrency = _prefs.getString(_currencyKey) ?? 'USD';
  }

  Future<void> setCurrency(String currencyCode) async {
    if (_exchangeRates.containsKey(currencyCode) && _currentCurrency != currencyCode) {
      _currentCurrency = currencyCode;
      await _prefs.setString(_currencyKey, currencyCode);
      notifyListeners();
    }
  }

  String formatCurrency(double value) {
    final rate = _exchangeRates[_currentCurrency] ?? 1.0;
    final symbol = _currencySymbols[_currentCurrency] ?? 'USD';
    final convertedValue = value * rate;

    // Use NumberFormat for consistent formatting (e.g., 1,234.56)
    final numberFormat = NumberFormat("#,##0.00", "en_US");

    return '${numberFormat.format(convertedValue)} $symbol';
  }

  String formatCurrencyWithCode(double amountInUsd) {
    final rate = _exchangeRates[_currentCurrency] ?? 1.0;
    final convertedAmount = amountInUsd * rate;
    return '${convertedAmount.toStringAsFixed(2)} $_currentCurrency';
  }

  double convert(double amountInUsd) {
     final rate = _exchangeRates[_currentCurrency] ?? 1.0;
     return amountInUsd * rate;
  }
}
