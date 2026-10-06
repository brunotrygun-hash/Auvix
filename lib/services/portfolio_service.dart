import '../models/asset_position.dart';

class PortfolioService {
  static List<AssetPosition> demoPortfolio() {
    return const [
      AssetPosition(
        ticker: 'BHIA3',
        company: 'Casas Bahia',
        quantity: 500,
        averagePrice: 3.20,
        currentPrice: 3.45,
        dailyChangePercent: 2.38,
      ),
    ];
  }
}
