import 'dart:async';

import 'package:flutter/material.dart';

import '../services/market_data_service.dart';
import '../theme/auvix_theme.dart';

class MarketTicker extends StatefulWidget {
  const MarketTicker({super.key});

  @override
  State<MarketTicker> createState() => _MarketTickerState();
}

class _MarketTickerState extends State<MarketTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _refreshTimer;

  List<MarketIndicator> _indicators = [];
  bool _loading = true;
  String? _errorMessage;

  static const Duration _refreshInterval = Duration(minutes: 30);

  static const Map<String, IconData> _icons = {
    'SELIC': Icons.account_balance,
    'DÓLAR': Icons.attach_money,
    'CDI': Icons.savings,
    'IPCA': Icons.trending_up,
  };

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();

    _loadIndicators();

    _refreshTimer = Timer.periodic(
      _refreshInterval,
      (_) => _loadIndicators(),
    );
  }

  Future<void> _loadIndicators() async {
    try {
      final results = await MarketDataService.fetchAll();

      if (!mounted) return;

      final today = DateTime.now();
      final validResults = results.where((indicator) {
        return !indicator.referenceDate.isAfter(
          DateTime(today.year, today.month, today.day),
        );
      }).toList();

      setState(() {
        _indicators = validResults;
        _loading = false;
        _errorMessage = validResults.isEmpty
            ? 'Dados indisponíveis'
            : null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = 'Falha ao consultar';
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Widget _buildItem(MarketIndicator indicator, double width) {
    final icon = _icons[indicator.name] ?? Icons.show_chart;

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: AuvixTheme.accent,
            ),
            const SizedBox(width: 6),
            Text(
              indicator.name,
              style: const TextStyle(
                color: AuvixTheme.accent,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${indicator.value} ${indicator.unit}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AuvixTheme.text,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    _formatDate(indicator.referenceDate),
                    style: const TextStyle(
                      color: AuvixTheme.muted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String message) {
    return SizedBox(
      width: 250,
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: AuvixTheme.muted,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _indicators;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 48,
          decoration: const BoxDecoration(
            color: AuvixTheme.surface,
            border: Border(
              top: BorderSide(color: Color(0xFF183A4A)),
              bottom: BorderSide(color: Color(0xFF183A4A)),
            ),
          ),
          child: ClipRect(
            child: _loading
                ? _buildPlaceholder('Consultando indicadores econômicos...')
                : items.isEmpty
                    ? _buildPlaceholder(
                        _errorMessage ?? 'Dados indisponíveis',
                      )
                    : AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          const itemWidth = 250.0;
                          final contentWidth = itemWidth * items.length;
                          final offset = _controller.value * contentWidth;

                          return Stack(
                            children: [
                              Positioned(
                                left: -offset,
                                top: 0,
                                bottom: 0,
                                child: Row(
                                  children: [
                                    ...items.map(
                                      (item) => _buildItem(
                                        item,
                                        itemWidth,
                                      ),
                                    ),
                                    ...items.map(
                                      (item) => _buildItem(
                                        item,
                                        itemWidth,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          child: Text(
            'Dados oficiais do Banco Central. '
            'Valores sujeitos à periodicidade de publicação. '
            'A data exibida é a referência do indicador.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AuvixTheme.muted,
              fontSize: 9,
            ),
          ),
        ),
      ],
    );
  }
}
