import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/asset_position.dart';
import '../services/portfolio_service.dart';
import '../theme/auvix_theme.dart';
import '../widgets/market_ticker.dart';
import '../widgets/home_sections.dart';
import '../widgets/economy_news_section.dart';

import 'add_asset_screen.dart';
import 'asset_detail_screen.dart';
import 'compound_interest_screen.dart';
import 'money_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late List<AssetPosition> positions;

  double _wealthContribution = 300;
  double _wealthRate = 0.008;
  int _wealthMonths = 60;
  double _wealthGoal = 50000;
  bool _hasWealthData = false;

  @override
  void initState() {
    super.initState();
    positions = PortfolioService.demoPortfolio();
    _loadWealthData();
  }

  Future<void> _loadWealthData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _wealthContribution =
          prefs.getDouble('wealth_contribution') ?? 300;

      _wealthRate = prefs.getDouble('wealth_rate') ?? 0.008;

      _wealthMonths = prefs.getInt('wealth_months') ?? 60;

      _wealthGoal = prefs.getDouble('wealth_goal') ?? 50000;

      _hasWealthData = prefs.containsKey('wealth_contribution');
    });
  }

  double get total =>
      positions.fold(0, (sum, item) => sum + item.currentValue);

  double get invested =>
      positions.fold(0, (sum, item) => sum + item.invested);

  double get profit => total - invested;

  void _addAsset() async {
    final position = await Navigator.of(context).push<AssetPosition>(
      MaterialPageRoute(
        builder: (_) => const AddAssetScreen(),
      ),
    );

    if (position != null) {
      setState(() {
        positions.add(position);
      });
    }
  }

  void _openMoney() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MoneyScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profitPercent =
        invested == 0 ? 0 : profit / invested * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AUVIX',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: CircleAvatar(
              radius: 17,
              child: Text('BF'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          8,
          18,
          28,
        ),
        children: [
          const Text(
            'Olá! 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Seu portfólio está em movimento.',
            style: TextStyle(
              color: AuvixTheme.muted,
            ),
          ),

          const MarketTicker(),
          const SizedBox(height: 18),

          _PortfolioCard(
            total: total,
            profit: profit,
            profitPercent: profitPercent.toDouble(),
            contribution: _wealthContribution,
            monthlyRate: _wealthRate,
            months: _wealthMonths,
            goal: _wealthGoal,
            hasWealthData: _hasWealthData,
          ),

          const SizedBox(height: 18),
          WealthAndDebtCards(onWealthUpdated: _loadWealthData),

          const HomeShortcuts(),
          const SizedBox(height: 22),
          const EconomyNewsSection(),
          const SizedBox(height: 22),
          const LearnInvestingBanner(),
          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AuvixTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF183A4A),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.calculate_rounded,
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Calculadora',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  'Simule o crescimento do seu dinheiro com juros compostos.',
                  style: TextStyle(
                    color: AuvixTheme.muted,
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const CompoundInterestScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '🧮 CALCULAR',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
               onDestinationSelected: (index) {
          if (index == 1) {
            _openMoney();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
            ),
            label: 'Início',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
            ),
            label: 'Dinheiro',
          ),


          NavigationDestination(
            icon: Icon(
              Icons.notifications_none_rounded,
            ),
            label: 'Alertas',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.menu_rounded,
            ),
            label: 'Mais',
          ),
        ],
      ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final double total;
  final double profit;
  final double profitPercent;
  final double contribution;
  final double monthlyRate;
  final int months;
  final double goal;
  final bool hasWealthData;

  const _PortfolioCard({
    required this.total,
    required this.profit,
    required this.profitPercent,
    required this.contribution,
    required this.monthlyRate,
    required this.months,
    required this.goal,
    required this.hasWealthData,
  });

  String money(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  double get totalInvested => contribution * months;

  double get futureValue {
    if (monthlyRate == 0) return totalInvested;

    return contribution *
        ((math.pow(1 + monthlyRate, months).toDouble() - 1) /
            monthlyRate);
  }

  double get interestEarned => futureValue - totalInvested;

  List<double> get chartValues {
    final values = <double>[];

    for (int i = 1; i <= 12; i++) {
      final month = (months * i / 12).ceil().clamp(1, months);

      final value = monthlyRate == 0
          ? contribution * month
          : contribution *
              ((math.pow(1 + monthlyRate, month).toDouble() - 1) /
                  monthlyRate);

      values.add(value);
    }

    return values;
  }

  Widget _indicator(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AuvixTheme.muted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AuvixTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF183A4A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patrimônio total',
            style: TextStyle(color: AuvixTheme.muted),
          ),
          const SizedBox(height: 4),
          Text(
            money(total),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '▲ +${money(profit)} '
            '(${profitPercent.toStringAsFixed(2).replaceAll('.', ',')}%)',
            style: const TextStyle(
              color: AuvixTheme.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hasWealthData) ...[
            const SizedBox(height: 18),
            const Divider(color: Color(0xFF183A4A)),
            const SizedBox(height: 10),
            const Text(
              'PROJEÇÃO DO SEU PATRIMÔNIO',
              style: TextStyle(
                color: AuvixTheme.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              money(futureValue),
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                color: AuvixTheme.accent,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _indicator(
                  'Aportado',
                  money(totalInvested),
                  const Color(0xFF19E6B0),
                ),
                _indicator(
                  'Juros',
                  money(interestEarned),
                  const Color(0xFFB58AFF),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _indicator(
                  'Prazo',
                  '$months meses',
                  const Color(0xFF55B9FF),
                ),
                _indicator(
                  'Meta',
                  money(goal),
                  const Color(0xFFFF9278),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            height: 70,
            child: hasWealthData
                ? CustomPaint(
                    size: Size.infinite,
                    painter: _MiniChartPainter(chartValues),
                  )
                : const Center(
                    child: Text(
                      'Configure sua projeção para visualizar o gráfico.',
                      style: TextStyle(
                        color: AuvixTheme.muted,
                        fontSize: 11,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  final List<double> values;

  _MiniChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.width <= 0 || size.height <= 0) {
      return;
    }

    double minValue = values.first;
    double maxValue = values.first;

    for (final value in values) {
      if (value < minValue) minValue = value;
      if (value > maxValue) maxValue = value;
    }

    final range = maxValue - minValue;

    final paint = Paint()
      ..color = AuvixTheme.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);

      final normalized = range == 0
          ? 0.5
          : (values[i] - minValue) / range;

      final y = size.height * (0.9 - normalized * 0.8);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniChartPainter oldDelegate) {
    return true;
  }
}

class _AssetTile extends StatelessWidget {
  final AssetPosition position;
  final VoidCallback onTap;

  const _AssetTile({
    required this.position,
    required this.onTap,
  });

  String money(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final variation =
        position.currentValue - position.invested;

    return Card(
      color: AuvixTheme.surface,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(
            position.ticker.substring(
              0,
              position.ticker.length > 2
                  ? 2
                  : position.ticker.length,
            ),
          ),
        ),
        title: Text(
          position.ticker,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '${position.quantity} ativos',
        ),
        trailing: Text(
          money(variation),
          style: TextStyle(
            color: variation >= 0
                ? AuvixTheme.accent
                : Colors.redAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
