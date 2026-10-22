import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class CurrencyService extends ChangeNotifier {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  String _currentCurrency = 'EUR';
  final Map<String, double> _rates = {
    'EUR': 1.0,
    'USD': 1.09,
    'GBP': 0.85,
    'INR': 91.20,
  };

  final Map<String, String> _symbols = {
    'EUR': '€',
    'USD': '\$',
    'GBP': '£',
    'INR': '₹',
  };

  String get currentCurrency => _currentCurrency;
  String get currencySymbol => _symbols[_currentCurrency] ?? '€';

  Future<void> fetchRatesFromBackend() async {
    try {
      final uri = Uri.parse(ApiConstants.currencyEndpoint);
      final res = await http.get(uri).timeout(const Duration(milliseconds: 2000));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['rates'] is Map) {
          final ratesMap = json['rates'] as Map<String, dynamic>;
          ratesMap.forEach((k, v) {
            _rates[k] = (v as num).toDouble();
          });
          notifyListeners();
        }
      }
    } catch (_) {
      // Retain fallback rates if offline
    }
  }

  void setCurrency(String currencyCode) {
    if (!_rates.containsKey(currencyCode)) return;
    _currentCurrency = currencyCode;
    notifyListeners();
  }

  double convertFromEur(double amountInEur) {
    double rate = _rates[_currentCurrency] ?? 1.0;
    return amountInEur * rate;
  }

  String format(double amountInEur) {
    double converted = convertFromEur(amountInEur);
    return '$currencySymbol${converted.toStringAsFixed(2)}';
  }
}
