import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/stock.dart';
import '../models/market_index.dart';
import '../models/historical_point.dart';
import '../models/news.dart';

class StockApiService {
  static final StockApiService _instance = StockApiService._internal();
  factory StockApiService() => _instance;
  StockApiService._internal();

  // Fallback stocks dataset conforming to plan.md
  static final List<Stock> _fallbackStocks = [
    Stock(
      symbol: 'SAP',
      companyName: 'SAP SE',
      exchange: 'XETRA',
      country: 'Germany',
      currency: 'EUR',
      price: 221.20,
      open: 217.50,
      high: 222.40,
      low: 216.80,
      previousClose: 213.89,
      change: 7.31,
      changePercent: 3.42,
      volume: 2145000,
      marketCap: '€262.4B',
      peRatio: 38.4,
      week52High: 224.50,
      week52Low: 119.80,
      sector: 'Enterprise Software',
    ),
    Stock(
      symbol: 'BMW',
      companyName: 'Bayerische Motoren Werke AG',
      exchange: 'XETRA',
      country: 'Germany',
      currency: 'EUR',
      price: 81.30,
      open: 83.20,
      high: 83.60,
      low: 80.90,
      previousClose: 83.09,
      change: -1.79,
      changePercent: -2.15,
      volume: 1420000,
      marketCap: '€51.8B',
      peRatio: 5.6,
      week52High: 115.35,
      week52Low: 77.20,
      sector: 'Automotive',
    ),
    Stock(
      symbol: 'SIE',
      companyName: 'Siemens AG',
      exchange: 'XETRA',
      country: 'Germany',
      currency: 'EUR',
      price: 183.40,
      open: 180.50,
      high: 184.20,
      low: 180.10,
      previousClose: 180.02,
      change: 3.38,
      changePercent: 1.88,
      volume: 1180000,
      marketCap: '€146.2B',
      peRatio: 17.2,
      week52High: 188.88,
      week52Low: 120.40,
      sector: 'Industrial Technology',
    ),
    Stock(
      symbol: 'VOW3',
      companyName: 'Volkswagen AG',
      exchange: 'XETRA',
      country: 'Germany',
      currency: 'EUR',
      price: 91.10,
      open: 91.80,
      high: 92.40,
      low: 90.60,
      previousClose: 91.50,
      change: -0.40,
      changePercent: -0.44,
      volume: 890000,
      marketCap: '€45.6B',
      peRatio: 3.8,
      week52High: 128.60,
      week52Low: 88.50,
      sector: 'Automotive',
    ),
    Stock(
      symbol: 'AAPL',
      companyName: 'Apple Inc.',
      exchange: 'NASDAQ',
      country: 'USA',
      currency: 'USD',
      price: 228.40,
      open: 225.80,
      high: 229.30,
      low: 225.10,
      previousClose: 224.23,
      change: 4.17,
      changePercent: 1.86,
      volume: 48200000,
      marketCap: '\$3.48T',
      peRatio: 34.2,
      week52High: 237.23,
      week52Low: 164.08,
      sector: 'Consumer Electronics',
    ),
    Stock(
      symbol: 'TSLA',
      companyName: 'Tesla, Inc.',
      exchange: 'NASDAQ',
      country: 'USA',
      currency: 'USD',
      price: 242.30,
      open: 249.00,
      high: 250.20,
      low: 240.10,
      previousClose: 248.00,
      change: -5.70,
      changePercent: -2.30,
      volume: 58200000,
      marketCap: '\$774.2B',
      peRatio: 61.2,
      week52High: 271.00,
      week52Low: 138.80,
      sector: 'Electric Vehicles',
    ),
    Stock(
      symbol: 'RELIANCE',
      companyName: 'Reliance Industries Ltd',
      exchange: 'NSE',
      country: 'India',
      currency: 'INR',
      price: 2980.50,
      open: 2940.00,
      high: 2995.00,
      low: 2935.00,
      previousClose: 2936.50,
      change: 44.00,
      changePercent: 1.50,
      volume: 4500000,
      marketCap: '₹20.1T',
      peRatio: 28.2,
      week52High: 3217.90,
      week52Low: 2221.05,
      sector: 'Conglomerate',
    ),
  ];

  static final Map<String, List<MarketIndex>> _fallbackIndices = {
    'Germany': [
      MarketIndex(symbol: 'DAX', name: 'DAX 40', price: 18942.31, change: 143.28, changePercent: 0.76),
      MarketIndex(symbol: 'MDAX', name: 'MDAX', price: 26521.10, change: -55.80, changePercent: -0.21),
      MarketIndex(symbol: 'TecDAX', name: 'TecDAX', price: 3412.45, change: 14.90, changePercent: 0.44),
    ],
    'USA': [
      MarketIndex(symbol: 'S&P 500', name: 'S&P 500', price: 5612.40, change: 38.50, changePercent: 0.69),
      MarketIndex(symbol: 'NASDAQ', name: 'NASDAQ Composite', price: 17683.98, change: 124.30, changePercent: 0.71),
      MarketIndex(symbol: 'DJIA', name: 'Dow Jones Industrial', price: 41535.07, change: -45.10, changePercent: -0.11),
    ],
    'United Kingdom': [
      MarketIndex(symbol: 'FTSE 100', name: 'FTSE 100 Index', price: 8273.43, change: 21.30, changePercent: 0.26),
      MarketIndex(symbol: 'FTSE 250', name: 'FTSE 250', price: 20780.12, change: -32.40, changePercent: -0.16),
    ],
    'India': [
      MarketIndex(symbol: 'NIFTY 50', name: 'Nifty 50 Index', price: 25377.80, change: 89.20, changePercent: 0.35),
      MarketIndex(symbol: 'SENSEX', name: 'BSE SENSEX', price: 82890.94, change: 236.80, changePercent: 0.29),
    ],
  };

  static final List<NewsArticle> _fallbackNews = [
    NewsArticle(
      id: 1,
      title: 'European Central Bank Signals Steady Course on Key Interest Rates',
      source: 'Financial Times',
      time: '15m ago',
      symbol: 'SAP',
      country: 'Germany',
      url: 'https://www.ft.com',
      summary: 'European tech and industrial leaders reacted positively to today\'s central bank policy briefing in Frankfurt.',
    ),
    NewsArticle(
      id: 2,
      title: 'Enterprise Cloud Demand Boosts SAP and Software Sector Margins',
      source: 'Reuters',
      time: '32m ago',
      symbol: 'SAP',
      country: 'Germany',
      url: 'https://www.reuters.com',
      summary: 'Analysts raised price targets following accelerated adoption of AI-infused ERP solutions across multinational clients.',
    ),
    NewsArticle(
      id: 3,
      title: 'Automotive Sector Faces Supply Chain Adjustments Across European Hubs',
      source: 'Bloomberg',
      time: '1h ago',
      symbol: 'BMW',
      country: 'Germany',
      url: 'https://www.bloomberg.com',
      summary: 'German auto manufacturers adjust battery material sourcing guidelines to reinforce domestic EV competitiveness.',
    ),
    NewsArticle(
      id: 4,
      title: 'Global Semiconductor Momentum Drives Tech Indices to Multi-Month Highs',
      source: 'Wall Street Journal',
      time: '2h ago',
      symbol: 'NVDA',
      country: 'USA',
      url: 'https://www.wsj.com',
      summary: 'Chip designers and equipment suppliers register strong institutional capital inflows following server hardware rollouts.',
    ),
  ];

  Future<List<MarketIndex>> getIndicesForCountry(String country) async {
    try {
      final uri = Uri.parse('${ApiConstants.searchEndpoint}?q=${Uri.encodeComponent(country)}');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 2000));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['countries'] is List && (json['countries'] as List).isNotEmpty) {
          final countriesList = json['countries'] as List;
          final cData = countriesList.firstWhere(
            (c) => c['name'].toString().toLowerCase() == country.toLowerCase(),
            orElse: () => countriesList.first,
          );
          if (cData != null && cData['indices'] is List) {
            return (cData['indices'] as List).map((idx) => MarketIndex.fromJson(idx)).toList();
          }
        }
      }
    } catch (_) {
      // Graceful fallback cache if backend is temporarily unreachable
    }
    return _fallbackIndices[country] ?? _fallbackIndices['Germany']!;
  }

  Future<List<Stock>> getStocksForCountry(String country) async {
    try {
      final uri = Uri.parse('${ApiConstants.searchEndpoint}?q=${Uri.encodeComponent(country)}');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 2000));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['stocks'] is List && (json['stocks'] as List).isNotEmpty) {
          return (json['stocks'] as List).map((s) => Stock.fromJson(s)).toList();
        }
      }
    } catch (_) {
      // Graceful fallback cache
    }
    final filtered = _fallbackStocks.where((s) => s.country.toLowerCase() == country.toLowerCase()).toList();
    return filtered.isNotEmpty ? filtered : _fallbackStocks;
  }

  Future<Stock> getStockDetail(String symbol) async {
    try {
      final uri = Uri.parse('${ApiConstants.stockEndpoint}?symbol=${Uri.encodeComponent(symbol)}');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 2000));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          return Stock.fromJson(json['data']);
        }
      }
    } catch (_) {
      // Fallback cache
    }

    // Match local
    final found = _fallbackStocks.firstWhere(
      (s) => s.symbol.toUpperCase() == symbol.toUpperCase(),
      orElse: () => Stock(
        symbol: symbol,
        companyName: '$symbol Corporation',
        exchange: 'XETRA',
        country: 'Germany',
        currency: 'EUR',
        price: 200.0,
        open: 198.0,
        high: 202.0,
        low: 197.0,
        previousClose: 196.0,
        change: 4.0,
        changePercent: 2.04,
        volume: 1200000,
        marketCap: '€50.0B',
        peRatio: 22.0,
        week52High: 215.0,
        week52Low: 160.0,
        sector: 'Technology',
      ),
    );
    return found;
  }

  Future<List<HistoricalPoint>> getHistoryPoints(String symbol, String range) async {
    try {
      final uri = Uri.parse('${ApiConstants.historyEndpoint}?symbol=${Uri.encodeComponent(symbol)}&range=${Uri.encodeComponent(range)}');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 2000));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['chart'] != null) {
          return (json['chart'] as List).map((p) => HistoricalPoint.fromJson(p)).toList();
        }
      }
    } catch (_) {}

    // Realistic rich fallback series with full OHLCV data
    return _generateFallbackPoints(symbol, range);
  }

  List<HistoricalPoint> _generateFallbackPoints(String symbol, String range) {
    double base = 150.0;
    for (var s in _fallbackStocks) {
      if (s.symbol.toUpperCase() == symbol.toUpperCase()) {
        base = s.price;
        break;
      }
    }

    int count = 24;
    switch (range.toUpperCase()) {
      case '1M_MIN':
      case '1M':
        // Could be 1m intraday or 1M month
        count = range.contains('m') ? 30 : 22;
        break;
      case '5M':
        count = 24;
        break;
      case '15M':
        count = 20;
        break;
      case '1H':
        count = 18;
        break;
      case '1D':
        count = 24;
        break;
      case '1W':
        count = 20;
        break;
      case '3M':
        count = 26;
        break;
      case '1Y':
        count = 30;
        break;
      case 'ALL':
        count = 36;
        break;
      default:
        count = 20;
    }

    final points = <HistoricalPoint>[];
    double current = base * 0.94;
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      final changeFactor = 1.0 + (((i * 17 + (symbol.hashCode % 13)) % 100) / 100.0 - 0.48) * 0.035;
      final open = current;
      final close = (current * changeFactor * 100).round() / 100.0;
      final high = ((((open > close ? open : close) + (base * 0.008))) * 100).round() / 100.0;
      final low = ((((open < close ? open : close) - (base * 0.007))) * 100).round() / 100.0;
      final volume = 15000 + ((i * 37 + symbol.hashCode.abs()) % 45000);

      String label;
      if (range == '1m' || range == '5m' || range == '15m') {
        final t = now.subtract(Duration(minutes: (count - 1 - i) * (range == '1m' ? 1 : range == '5m' ? 5 : 15)));
        label = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      } else if (range == '1H') {
        final t = now.subtract(Duration(hours: count - 1 - i));
        label = '${t.hour.toString().padLeft(2, '0')}:00';
      } else if (range == '1D') {
        final startH = 9 + (i * 8 ~/ count);
        final startM = (i * 20) % 60;
        label = '${startH.toString().padLeft(2, '0')}:${startM.toString().padLeft(2, '0')}';
      } else if (range == '1W') {
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
        label = days[i % days.length];
      } else if (range == '1M' || range == '3M') {
        final day = (i * 3 + 1).clamp(1, 28);
        label = '$day Sep';
      } else {
        label = '${2020 + (i ~/ 6)} Q${(i % 4) + 1}';
      }

      points.add(HistoricalPoint(
        date: label,
        close: close,
        open: open,
        high: high,
        low: low,
        volume: volume,
      ));
      current = close;
    }
    return points;
  }


  Future<List<HistoricalTableRow>> getHistoricalTable(String symbol) async {
    try {
      final uri = Uri.parse('${ApiConstants.historyEndpoint}?symbol=${Uri.encodeComponent(symbol)}');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 2000));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['table'] is List) {
          return (json['table'] as List).map((r) => HistoricalTableRow.fromJson(r)).toList();
        }
      }
    } catch (_) {}

    final base = (symbol == 'BMW') ? 81.30 : 221.20;
    return [
      HistoricalTableRow(date: '22 Sep', open: base * 0.99, high: base * 1.01, low: base * 0.98, close: base, volume: '2,145,000'),
      HistoricalTableRow(date: '21 Sep', open: base * 0.98, high: base * 1.00, low: base * 0.97, close: base * 0.99, volume: '1,980,000'),
      HistoricalTableRow(date: '20 Sep', open: base * 0.97, high: base * 0.99, low: base * 0.96, close: base * 0.98, volume: '2,310,000'),
      HistoricalTableRow(date: '19 Sep', open: base * 0.96, high: base * 0.98, low: base * 0.95, close: base * 0.97, volume: '1,850,000'),
      HistoricalTableRow(date: '18 Sep', open: base * 0.95, high: base * 0.97, low: base * 0.94, close: base * 0.96, volume: '2,020,000'),
    ];
  }

  Future<List<NewsArticle>> getNews({String? symbol}) async {
    try {
      final queryParam = symbol != null ? '?symbol=${Uri.encodeComponent(symbol)}' : '';
      final uri = Uri.parse('${ApiConstants.newsEndpoint}$queryParam');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 2000));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['news'] is List && (json['news'] as List).isNotEmpty) {
          return (json['news'] as List).map((n) => NewsArticle.fromJson(n)).toList();
        }
      }
    } catch (_) {}

    if (symbol != null) {
      final filtered = _fallbackNews.where((n) => n.symbol.toUpperCase() == symbol.toUpperCase()).toList();
      if (filtered.isNotEmpty) return filtered;
    }
    return _fallbackNews;
  }
}
