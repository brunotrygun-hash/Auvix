class AssetPosition {
  final String ticker;
  final String company;
  final double quantity;
  final double averagePrice;
  final double currentPrice;
  final double dailyChangePercent;

  const AssetPosition({
    required this.ticker,
    required this.company,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
    required this.dailyChangePercent,
  });

  double get invested => quantity * averagePrice;
  double get currentValue => quantity * currentPrice;
  double get profit => currentValue - invested;
  double get returnPercent => invested == 0 ? 0 : (profit / invested) * 100;
}
