class PortfolioItem {
  final int id;
  final String symbol;
  final int quantity;
  final double purchasePrice;

  PortfolioItem({
    required this.id,
    required this.symbol,
    required this.quantity,
    required this.purchasePrice,
  });

  double get investedValue => quantity * purchasePrice;

  double calculateCurrentValue(double currentPrice) => quantity * currentPrice;

  double calculateProfitLoss(double currentPrice) => calculateCurrentValue(currentPrice) - investedValue;

  double calculateProfitLossPercent(double currentPrice) {
    if (investedValue == 0) return 0.0;
    return (calculateProfitLoss(currentPrice) / investedValue) * 100;
  }

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: (json['id'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      symbol: json['symbol'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
    };
  }
}
