class HistoricalPoint {
  final String date;
  final double close;
  final double open;
  final double high;
  final double low;
  final int volume;

  HistoricalPoint({
    required this.date,
    required this.close,
    this.open = 0.0,
    this.high = 0.0,
    this.low = 0.0,
    this.volume = 0,
  });

  factory HistoricalPoint.fromJson(Map<String, dynamic> json) {
    final c = (json['close'] as num?)?.toDouble() ?? 0.0;
    return HistoricalPoint(
      date: json['date'] ?? '',
      close: c,
      open: (json['open'] as num?)?.toDouble() ?? c,
      high: (json['high'] as num?)?.toDouble() ?? c,
      low: (json['low'] as num?)?.toDouble() ?? c,
      volume: (json['volume'] as num?)?.toInt() ?? 0,
    );
  }
}

class HistoricalTableRow {
  final String date;
  final double open;
  final double high;
  final double low;
  final double close;
  final String volume;

  HistoricalTableRow({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory HistoricalTableRow.fromJson(Map<String, dynamic> json) {
    return HistoricalTableRow(
      date: json['date'] ?? '',
      open: (json['open'] as num?)?.toDouble() ?? 0.0,
      high: (json['high'] as num?)?.toDouble() ?? 0.0,
      low: (json['low'] as num?)?.toDouble() ?? 0.0,
      close: (json['close'] as num?)?.toDouble() ?? 0.0,
      volume: json['volume']?.toString() ?? '',
    );
  }
}
