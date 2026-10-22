import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistService extends ChangeNotifier {
  static final WatchlistService _instance = WatchlistService._internal();
  factory WatchlistService() => _instance;
  WatchlistService._internal() {
    _load();
  }

  List<String> _symbols = ['SAP'];

  List<String> get symbols => _symbols;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('mp_mobile_watchlist');
      if (list != null && list.isNotEmpty) {
        _symbols = list;
        notifyListeners();
      }
    } catch (_) {}
  }

  bool isWatched(String symbol) {
    return _symbols.contains(symbol.toUpperCase().trim());
  }

  Future<void> toggle(String symbol) async {
    final sym = symbol.toUpperCase().trim();
    if (_symbols.contains(sym)) {
      _symbols.remove(sym);
    } else {
      _symbols.add(sym);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('mp_mobile_watchlist', _symbols);
    } catch (_) {}
  }
}
