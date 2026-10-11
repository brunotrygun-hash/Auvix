import 'package:flutter/material.dart';
import '../theme/auvix_theme.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final List<String> _assets = [
    'PETR4',
    'VALE3',
    'ITUB4',
    'BBAS3',
    'BBDC4',
    'WEGE3',
    'ABEV3',
    'BBSE3',
    'B3SA3',
    'TAEE11',
    'EGIE3',
    'PRIO3',
  ];

  final Set<String> _favorites = {};

  String get _search => _searchController.text.trim().toUpperCase();

  List<String> get _filteredAssets {
    final filtered = _assets
        .where((ticker) => ticker.contains(_search))
        .toList();

    filtered.sort((a, b) {
      final aFavorite = _favorites.contains(a);
      final bFavorite = _favorites.contains(b);

      if (aFavorite == bFavorite) return a.compareTo(b);
      return aFavorite ? -1 : 1;
    });

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFavorite(String ticker) {
    setState(() {
      if (_favorites.contains(ticker)) {
        _favorites.remove(ticker);
      } else {
        _favorites.add(ticker);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final assets = _filteredAssets;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mercado',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AuvixTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF183A4A),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.show_chart_rounded,
                  color: AuvixTheme.accent,
                  size: 34,
                ),
                SizedBox(height: 12),
                Text(
                  'Explore a B3',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Encontre ativos e monte sua lista de acompanhamento.',
                  style: TextStyle(
                    color: AuvixTheme.muted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _searchController,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Pesquisar ativo (ex.: PETR4)',
              prefixIcon: Icon(Icons.search_rounded),
              suffixIcon: Icon(Icons.tune_rounded),
            ),
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ativos para acompanhar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${assets.length}',
                style: const TextStyle(
                  color: AuvixTheme.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AuvixTheme.surface2,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AuvixTheme.accent,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Esta lista ainda não exibe cotações. '
                    'Os preços reais serão apresentados após '
                    'a integração com uma fonte de dados de mercado.',
                    style: TextStyle(
                      color: AuvixTheme.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (assets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Nenhum ativo encontrado.',
                  style: TextStyle(
                    color: AuvixTheme.muted,
                  ),
                ),
              ),
            ),

          ...assets.map((ticker) {
            final favorite = _favorites.contains(ticker);

            return Card(
              color: AuvixTheme.surface,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AuvixTheme.surface2,
                  child: Text(
                    ticker.substring(0, 2),
                    style: const TextStyle(
                      color: AuvixTheme.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                title: Text(
                  ticker,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  favorite ? 'Na sua lista de favoritos' : 'Ação listada para acompanhamento',
                  style: const TextStyle(
                    color: AuvixTheme.muted,
                    fontSize: 12,
                  ),
                ),
                trailing: IconButton(
                  tooltip: favorite
                      ? 'Remover dos favoritos'
                      : 'Adicionar aos favoritos',
                  onPressed: () => _toggleFavorite(ticker),
                  icon: Icon(
                    favorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: favorite
                        ? AuvixTheme.accent
                        : AuvixTheme.muted,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
