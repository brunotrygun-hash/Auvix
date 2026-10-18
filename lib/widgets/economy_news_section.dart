import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/economy_news_service.dart';
import '../theme/auvix_theme.dart';

class EconomyNewsSection extends StatefulWidget {
  const EconomyNewsSection({super.key});

  @override
  State<EconomyNewsSection> createState() => _EconomyNewsSectionState();
}

class _EconomyNewsSectionState extends State<EconomyNewsSection> {
  late Future<List<EconomyNews>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = EconomyNewsService.fetchNews();
  }

  void _refresh() {
    setState(() {
      _newsFuture = EconomyNewsService.fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Economia em Foco',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              onPressed: _refresh,
              tooltip: 'Atualizar notícias',
              icon: const Icon(
                Icons.refresh_rounded,
                color: AuvixTheme.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Notícias para entender o cenário econômico.',
          style: TextStyle(color: AuvixTheme.muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<EconomyNews>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _messageCard(
                const CircularProgressIndicator(
                  color: AuvixTheme.accent,
                ),
                'Buscando notícias recentes...',
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return _messageCard(
                const Icon(
                  Icons.wifi_off_rounded,
                  color: AuvixTheme.accent,
                  size: 30,
                ),
                'Nenhuma notícia encontrada no momento. Toque no botão de atualizar para tentar novamente.',
              );
            }

            final news = snapshot.data!;
            return Column(
              children: [
                _featuredCard(news.first),
                if (news.length > 1) ...[
                  const SizedBox(height: 12),
                  ...news.skip(1).take(4).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _compactCard(item),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 6),
        const Text(
          'Conteúdo informativo. Consulte a fonte original para mais detalhes.',
          style: TextStyle(color: AuvixTheme.muted, fontSize: 10),
        ),
      ],
    );
  }

  Widget _messageCard(Widget icon, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _decoration(),
      child: Row(
        children: [
          SizedBox(width: 34, height: 34, child: Center(child: icon)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AuvixTheme.muted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuredCard(EconomyNews news) {
    return Material(
      color: AuvixTheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openDetails(news),
        child: Container(
          decoration: _decoration(),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _newsImage(news.imageUrl, height: 175),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _badge('DESTAQUE DO DIA'),
                    const SizedBox(height: 10),
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _shorten(news.summary, 190),
                      style: const TextStyle(
                        color: AuvixTheme.muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _metadata(news),
                    const SizedBox(height: 14),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Ler notícia',
                          style: TextStyle(
                            color: AuvixTheme.accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: AuvixTheme.accent,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactCard(EconomyNews news) {
    return Material(
      color: AuvixTheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openDetails(news),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: _decoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _newsImage(news.imageUrl, height: 76, width: 82),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${news.source} • ${_formatDate(news.publishedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AuvixTheme.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _newsImage(
    String? url, {
    double height = 120,
    double width = double.infinity,
  }) {
    if (url != null && url.startsWith('https://')) {
      return Image.network(
        url,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(height, width),
      );
    }
    return _imageFallback(height, width);
  }

  Widget _imageFallback(double height, double width) {
    return Container(
      height: height,
      width: width,
      color: const Color(0xFF102A38),
      child: const Center(
        child: Icon(
          Icons.query_stats_rounded,
          color: AuvixTheme.accent,
          size: 38,
        ),
      ),
    );
  }

  Widget _metadata(EconomyNews news) {
    return Wrap(
      spacing: 8,
      runSpacing: 5,
      children: [
        Text(
          news.source,
          style: const TextStyle(
            color: AuvixTheme.accent,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '• ${_formatDate(news.publishedAt)}',
          style: const TextStyle(color: AuvixTheme.muted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AuvixTheme.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AuvixTheme.accent,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: AuvixTheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF183A4A)),
    );
  }

  String _shorten(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength).trimRight()}...';
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  void _openDetails(EconomyNews news) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EconomyNewsDetailScreen(news: news),
      ),
    );
  }
}

class EconomyNewsDetailScreen extends StatelessWidget {
  final EconomyNews news;

  const EconomyNewsDetailScreen({super.key, required this.news});

  Future<void> _openOriginal(BuildContext context) async {
    final uri = Uri.tryParse(news.url);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link da notícia inválido.')),
      );
      return;
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir a notícia.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuvixTheme.background,
      appBar: AppBar(
        backgroundColor: AuvixTheme.background,
        title: const Text('Economia em Foco'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: news.imageUrl != null &&
                    news.imageUrl!.startsWith('https://')
                ? Image.network(
                    news.imageUrl!,
                    height: 210,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _detailFallback(),
                  )
                : _detailFallback(),
          ),
          const SizedBox(height: 18),
          Text(
            news.title,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${news.source} • ${news.publishedAt.toLocal().day.toString().padLeft(2, '0')}/${news.publishedAt.toLocal().month.toString().padLeft(2, '0')}/${news.publishedAt.toLocal().year}',
            style: const TextStyle(
              color: AuvixTheme.accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Resumo disponível',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            news.summary.isEmpty
                ? 'O feed não disponibilizou um resumo para esta publicação.'
                : news.summary,
            style: const TextStyle(
              color: AuvixTheme.muted,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AuvixTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF183A4A)),
            ),
            child: const Text(
              'Por que acompanhar?\\n'
              'Notícias econômicas podem ajudar a compreender o cenário '
              'de juros, inflação, câmbio e mercado. O efeito de cada '
              'acontecimento depende do contexto e não representa, por si só, '
              'uma recomendação de investimento.',
              style: TextStyle(color: AuvixTheme.muted, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openOriginal(context),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Ler matéria na fonte original'),
              style: FilledButton.styleFrom(
                backgroundColor: AuvixTheme.accent,
                foregroundColor: AuvixTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Conteúdo informativo. AUVIX não recomenda compra ou venda de ativos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AuvixTheme.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _detailFallback() {
    return Container(
      height: 210,
      color: AuvixTheme.surface2,
      child: const Center(
        child: Icon(
          Icons.query_stats_rounded,
          color: AuvixTheme.accent,
          size: 64,
        ),
      ),
    );
  }
}
