import 'package:flutter/material.dart';

import '../models/asset_position.dart';
import '../services/portfolio_service.dart';
import '../theme/auvix_theme.dart';

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

  @override
  void initState() {
    super.initState();
    positions = PortfolioService.demoPortfolio();
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

          const SizedBox(height: 18),

          _PortfolioCard(
            total: total,
            profit: profit,
            profitPercent: profitPercent.toDouble(),
          ),

          const SizedBox(height: 18),

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

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meus Ativos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ...positions.map(
            (position) => _AssetTile(
              position: position,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AssetDetailScreen(
                      position: position,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: _addAsset,
            icon: const Icon(
              Icons.add_rounded,
            ),
            label: const Text(
              'Adicionar ativo',
            ),
          ),
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
              Icons.show_chart_rounded,
            ),
            label: 'Mercado',
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

  const _PortfolioCard({
    required this.total,
    required this.profit,
    required this.profitPercent,
  });

  String money(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
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
            style: TextStyle(
              color: AuvixTheme.muted,
            ),
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

          const SizedBox(height: 18),

          SizedBox(
            height: 70,
            child: CustomPaint(
              painter: _MiniChartPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = AuvixTheme.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final points = [
      0.05,
      0.24,
      0.18,
      0.38,
      0.31,
      0.48,
      0.43,
      0.62,
      0.57,
      0.72,
      0.68,
      0.91,
    ];

    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final x = size.width *
          i /
          (points.length - 1);

      final y = size.height *
          (1 - points[i]);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
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
