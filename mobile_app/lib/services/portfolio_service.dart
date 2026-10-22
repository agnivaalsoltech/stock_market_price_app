import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/portfolio_item.dart';
import 'stock_api_service.dart';

class PortfolioService extends ChangeNotifier {
  static final PortfolioService _instance = PortfolioService._internal();
  factory PortfolioService() => _instance;
  PortfolioService._internal();

  List<PortfolioItem> _items = [];
  bool _isLoading = false;

  List<PortfolioItem> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadPortfolio() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString('mp_mobile_portfolio');
      if (savedStr != null && savedStr.isNotEmpty) {
        final List decoded = jsonDecode(savedStr);
        _items = decoded.map((item) => PortfolioItem.fromJson(item)).toList();
      } else {
        // Initial default positions matching plan.md (SAP 10 shares @ 195, BMW 15 shares @ 86)
        _items = [
          PortfolioItem(id: 1, symbol: 'SAP', quantity: 10, purchasePrice: 195.0),
          PortfolioItem(id: 2, symbol: 'BMW', quantity: 15, purchasePrice: 86.0),
        ];
        await _save();
      }
    } catch (_) {
      _items = [
        PortfolioItem(id: 1, symbol: 'SAP', quantity: 10, purchasePrice: 195.0),
        PortfolioItem(id: 2, symbol: 'BMW', quantity: 15, purchasePrice: 86.0),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHolding(String symbol, int qty, double buyPrice) async {
    _items.add(PortfolioItem(
      id: DateTime.now().millisecondsSinceEpoch,
      symbol: symbol.toUpperCase().trim(),
      quantity: qty,
      purchasePrice: buyPrice,
    ));
    await _save();
    notifyListeners();
  }

  Future<void> removeHolding(int id) async {
    _items.removeWhere((item) => item.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> resetToDemo() async {
    _items = [
      PortfolioItem(id: 1, symbol: 'SAP', quantity: 10, purchasePrice: 195.0),
      PortfolioItem(id: 2, symbol: 'BMW', quantity: 15, purchasePrice: 86.0),
      PortfolioItem(id: 3, symbol: 'SIE', quantity: 8, purchasePrice: 175.0),
    ];
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = jsonEncode(_items.map((i) => i.toJson()).toList());
      await prefs.setString('mp_mobile_portfolio', str);
    } catch (_) {}
  }

  double calculateTotalInvested() {
    return _items.fold(0.0, (sum, item) => sum + item.investedValue);
  }

  Future<double> calculateTotalCurrentValue(StockApiService apiService) async {
    double total = 0.0;
    for (final item in _items) {
      final stock = await apiService.getStockDetail(item.symbol);
      total += item.calculateCurrentValue(stock.price);
    }
    return total;
  }
}
