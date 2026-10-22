class Stock {
  final String symbol;
  final String companyName;
  final String exchange;
  final String country;
  final String currency;
  final double price;
  final double open;
  final double high;
  final double low;
  final double previousClose;
  final double change;
  final double changePercent;
  final int volume;
  final String marketCap;
  final double peRatio;
  final double week52High;
  final double week52Low;
  final String sector;

  Stock({
    required this.symbol,
    required this.companyName,
    required this.exchange,
    required this.country,
    required this.currency,
    required this.price,
    required this.open,
    required this.high,
    required this.low,
    required this.previousClose,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.marketCap,
    required this.peRatio,
    required this.week52High,
    required this.week52Low,
    required this.sector,
  });

  bool get isPositive => change >= 0;

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] ?? '',
      companyName: json['companyName'] ?? '',
      exchange: json['exchange'] ?? '',
      country: json['country'] ?? 'Germany',
      currency: json['currency'] ?? 'EUR',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      open: (json['open'] as num?)?.toDouble() ?? 0.0,
      high: (json['high'] as num?)?.toDouble() ?? 0.0,
      low: (json['low'] as num?)?.toDouble() ?? 0.0,
      previousClose: (json['previousClose'] as num?)?.toDouble() ?? 0.0,
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0.0,
      volume: (json['volume'] as num?)?.toInt() ?? 0,
      marketCap: json['marketCap']?.toString() ?? '€0.0B',
      peRatio: (json['peRatio'] as num?)?.toDouble() ?? 0.0,
      week52High: (json['week52High'] as num?)?.toDouble() ?? 0.0,
      week52Low: (json['week52Low'] as num?)?.toDouble() ?? 0.0,
      sector: json['sector'] ?? 'Equities',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'companyName': companyName,
      'exchange': exchange,
      'country': country,
      'currency': currency,
      'price': price,
      'open': open,
      'high': high,
      'low': low,
      'previousClose': previousClose,
      'change': change,
      'changePercent': changePercent,
      'volume': volume,
      'marketCap': marketCap,
      'peRatio': peRatio,
      'week52High': week52High,
      'week52Low': week52Low,
      'sector': sector,
    };
  }
}
