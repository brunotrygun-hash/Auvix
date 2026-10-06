import 'package:flutter/material.dart';
import '../models/asset_position.dart';
import '../theme/auvix_theme.dart';

class AssetDetailScreen extends StatelessWidget {
  final AssetPosition position;
  const AssetDetailScreen({super.key, required this.position});
  String money(double value) => 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  @override
  Widget build(BuildContext context) {
    final positive = position.dailyChangePercent >= 0;
    return Scaffold(
      appBar: AppBar(title: Text(position.ticker), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.star_border_rounded))]),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Text(position.company, style: const TextStyle(color: AuvixTheme.muted)),
        const SizedBox(height: 8),
        Text(money(position.currentPrice), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
        Text('${positive ? '▲' : '▼'} ${position.dailyChangePercent.toStringAsFixed(2).replaceAll('.', ',')}% hoje', style: TextStyle(color: positive ? AuvixTheme.accent : AuvixTheme.danger, fontWeight: FontWeight.w700)),
        const SizedBox(height: 24),
        Container(height: 220, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AuvixTheme.surface, borderRadius: BorderRadius.circular(20)), child: CustomPaint(painter: _DetailChartPainter())),
        const SizedBox(height: 22),
        const Text('Minha posição', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        _Info('Quantidade', position.quantity.toStringAsFixed(0)),
        _Info('Preço médio', money(position.averagePrice)),
        _Info('Investido', money(position.invested)),
        _Info('Valor atual', money(position.currentValue)),
        _Info('Lucro / Prejuízo', money(position.profit)),
        _Info('Rentabilidade', '${position.returnPercent.toStringAsFixed(2).replaceAll('.', ',')}%'),
      ]),
    );
  }
}
class _Info extends StatelessWidget { final String label, value; const _Info(this.label, this.value); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: AuvixTheme.muted)), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))])); }
class _DetailChartPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) { final p = Paint()..color = AuvixTheme.accent..style = PaintingStyle.stroke..strokeWidth = 3; final path = Path(); final pts = [0.78,.69,.74,.55,.61,.42,.47,.33,.38,.21,.26,.12]; for (var i=0;i<pts.length;i++){final x=size.width*i/(pts.length-1); final y=size.height*pts[i]; if(i==0)path.moveTo(x,y);else path.lineTo(x,y);} canvas.drawPath(path,p); }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}
