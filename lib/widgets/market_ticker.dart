import 'package:flutter/material.dart';
import '../theme/auvix_theme.dart';

class MarketTicker extends StatefulWidget {
  const MarketTicker({super.key});

  @override
  State<MarketTicker> createState() => _MarketTickerState();
}

class _MarketTickerState extends State<MarketTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<_TickerItem> _items = [
    _TickerItem('SELIC', 'Consulte a taxa oficial', Icons.account_balance),
    _TickerItem('IBOVESPA', 'Acompanhe o índice', Icons.show_chart),
    _TickerItem('DÓLAR', 'Consulte a cotação', Icons.attach_money),
    _TickerItem('CDI', 'Acompanhe a taxa', Icons.savings),
    _TickerItem('IPCA', 'Acompanhe a inflação', Icons.trending_up),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: const BoxDecoration(
        color: AuvixTheme.surface,
        border: Border(
          top: BorderSide(color: Color(0xFF183A4A)),
          bottom: BorderSide(color: Color(0xFF183A4A)),
        ),
      ),
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = 190.0;
                final contentWidth = itemWidth * _items.length;
                final offset = _controller.value * contentWidth;

                return Stack(
                  children: [
                    Positioned(
                      left: -offset,
                      top: 0,
                      bottom: 0,
                      child: Row(
                        children: [
                          ..._items.map(
                            (item) => _buildItem(item, itemWidth),
                          ),
                          ..._items.map(
                            (item) => _buildItem(item, itemWidth),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(_TickerItem item, double width) {
    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            size: 16,
            color: AuvixTheme.accent,
          ),
          const SizedBox(width: 7),
          Text(
            item.label,
            style: const TextStyle(
              color: AuvixTheme.accent,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              item.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AuvixTheme.text,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TickerItem {
  final String label;
  final String description;
  final IconData icon;

  const _TickerItem(this.label, this.description, this.icon);
}
