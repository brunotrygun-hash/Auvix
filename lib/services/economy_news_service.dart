import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class EconomyNews {
  final String title;
  final String summary;
  final String source;
  final String url;
  final DateTime publishedAt;
  final String? imageUrl;

  const EconomyNews({
    required this.title,
    required this.summary,
    required this.source,
    required this.url,
    required this.publishedAt,
    this.imageUrl,
  });
}

class EconomyNewsService {
  static DateTime? _parseDate(String value) {
    try {
      return HttpDate.parse(value);
    } catch (_) {
      return DateTime.tryParse(value);
    }
  }

  static const List<String> _queries = [
    'economia Brasil when:3d',
    'Selic inflação Banco Central when:3d',
    'dólar Ibovespa empresas bancos when:3d',
  ];

  static Future<List<EconomyNews>> fetchNews() async {
    final client = http.Client();

    try {
      final results = await Future.wait(
        _queries.map((query) async {
          try {
            final uri = Uri.https(
              'news.google.com',
              '/rss/search',
              {
                'q': query,
                'hl': 'pt-BR',
                'gl': 'BR',
                'ceid': 'BR:pt-419',
              },
            );

            final response = await client.get(
              uri,
              headers: {'User-Agent': 'Mozilla/5.0 AUVIX'},
            ).timeout(const Duration(seconds: 12));

            if (response.statusCode != 200) {
              print("AUVIX noticias: HTTP ${response.statusCode} na pesquisa: $query");
              return <EconomyNews>[];
            }

            final document = XmlDocument.parse(response.body);

            return document.findAllElements('item').map((item) {
              String value(String name) =>
                  item.getElement(name)?.innerText.trim() ?? '';

              final title = value('title');
              final description = value('description');
              final url = value('link');
              final date = _parseDate(value('pubDate'));

              final imageMatch = RegExp(
                r'''src=["']([^"']+)["']''',
                caseSensitive: false,
              ).firstMatch(description);

              final image = imageMatch?.group(1);

              final summary = description
                  .replaceAll(
                    RegExp(r'<[^>]*>'),
                    ' ',
                  )
                  .replaceAll('&nbsp;', ' ')
                  .replaceAll('&quot;', '"')
                  .replaceAll('&#39;', "'")
                  .replaceAll('&amp;', '&')
                  .replaceAll(RegExp(r'\s+'), ' ')
                  .trim();

              final sourceElement = item.getElement('source');
              final source = sourceElement?.innerText.trim().isNotEmpty == true
                  ? sourceElement!.innerText.trim()
                  : 'Google Notícias';

              return EconomyNews(
                title: title,
                summary: summary,
                source: source,
                url: url,
                publishedAt: date ?? DateTime(1970),
                imageUrl: image,
              );
            }).where((news) {
              final age = DateTime.now().difference(news.publishedAt);
              return news.title.isNotEmpty &&
                  news.url.startsWith('http') &&
                  age.inHours >= -1 &&
                  age.inHours <= 168;
            }).toList();
          } catch (e, stackTrace) {
            print("AUVIX noticias: erro ao consultar RSS: $e");
            print(stackTrace);
            return <EconomyNews>[];
          }
        }),
      );

      final unique = <String, EconomyNews>{};

      for (final group in results) {
        for (final news in group) {
          unique.putIfAbsent(news.url, () => news);
        }
      }

      final news = unique.values.toList()
        ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      return news;
    } catch (_) {
      return [];
    } finally {
      client.close();
    }
  }
}

