import 'package:flutter/material.dart';
import '../models/asset_position.dart';
import '../services/portfolio_service.dart';
import '../theme/auvix_theme.dart';
import 'add_asset_screen.dart';
import 'asset_detail_screen.dart';

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

  double get total => positions.fold(0, (sum, item) => sum + item.currentValue);
  double get invested => positions.fold(0, (sum, item) => sum + item.invested);
  double get profit => total - invested;

  void _addAsset() async {
    final position = await Navigator.of(context).push<AssetPosition>(
      MaterialPageRoute(builder: (_) => const AddAssetScreen()),
    );
    if (position != null) setState(() => positions.add(position));
  }

  @override
  Widget build(BuildContext context) {
    final profitPercent = invested == 0 ? 0 : profit / invested * 100;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AUVIX', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)), const Padding(padding: EdgeInsets.only(right: 14), child: CircleAvatar(radius: 17, child: Text('BF')))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          const Text('Olá! 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Seu portfólio está em movimento.', style: TextStyle(color: AuvixTheme.muted)),
          const SizedBox(height: 18),
          _PortfolioCard(total: total, profit: profit, profitPercent: profitPercent.toDouble()),
          const SizedBox(height: 26),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Meus Ativos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), TextButton(onPressed: _addAsset, child: const Text('Adicionar'))]),
          const SizedBox(height: 8),
          ...positions.map((position) => _AssetTile(position: position, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AssetDetailScreen(position: position))))),
          const SizedBox(height: 16),
          OutlinedButton.icon(onPressed: _addAsset, icon: const Icon(Icons.add_rounded), label: const Text('Adicionar ativo')),
        ],
      ),
      bottomNavigationBar: NavigationBar(selectedIndex: 0, onDestinationSelected: (_) {}, destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Início'), NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Carteira'), NavigationDestination(icon: Icon(Icons.show_chart_rounded), label: 'Mercado'), NavigationDestination(icon: Icon(Icons.notifications_none_rounded), label: 'Alertas'), NavigationDestination(icon: Icon(Icons.menu_rounded), label: 'Mais')]),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final double total, profit, profitPercent;
  const _PortfolioCard({required this.total, required this.profit, required this.profitPercent});
  String money(double value) => 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AuvixTheme.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF183A4A))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Patrimônio total', style: TextStyle(color: AuvixTheme.muted)),
        const SizedBox(height: 4),
        Text(money(total), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('▲ +${money(profit)} (${profitPercent.toStringAsFixed(2).replaceAll('.', ',')}%)', style: const TextStyle(color: AuvixTheme.accent, fontWeight: FontWeight.w700)),
        const SizedBox(height: 18),
        SizedBox(height: 70, child: CustomPaint(painter: _MiniChartPainter())),
      ]),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AuvixTheme.accent..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final points = [0.05, .24, .18, .38, .31, .48, .43, .62, .57, .72, .68, .91];
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height * (1 - points[i]);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AssetTile extends StatelessWidget {
  final AssetPosition position;
  final VoidCallback onTap;
  const _AssetTile({required this.position, required this.onTap});
  String money(double value) => 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  @override
  Widget build(BuildContext context) {
    final positive = position.dailyChangePercent >= 0;
    return Card(
      color: AuvixTheme.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF153443))),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: AuvixTheme.surface2, child: Text(position.ticker.substring(0, 1))),
        title: Text(position.ticker, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(position.company, style: const TextStyle(color: AuvixTheme.muted)),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text(money(position.currentPrice), style: const TextStyle(fontWeight: FontWeight.w700)), Text('${positive ? '▲' : '▼'} ${position.dailyChangePercent.toStringAsFixed(2).replaceAll('.', ',')}%', style: TextStyle(color: positive ? AuvixTheme.accent : AuvixTheme.danger, fontSize: 12, fontWeight: FontWeight.w700))]),
      ),
    );
  }
}
