import 'dart:io';
import 'package:html/parser.dart' as html_parser;
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
  static Future<String?> _fetchImage(String articleUrl) async {
    try {
      final response = await http.get(
        Uri.parse(articleUrl),
        headers: {
          "User-Agent": "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36",
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final document = html_parser.parse(response.body);
      final candidates = [
        document.querySelector('meta[property="og:image"]')?.attributes["content"],
        document.querySelector('meta[name="twitter:image"]')?.attributes["content"],
      ];

      for (final candidate in candidates) {
        if (candidate == null || candidate.trim().isEmpty) continue;
        final imageUri = Uri.tryParse(candidate.trim());
        if (imageUri == null) continue;
        final resolved = imageUri.hasScheme
            ? imageUri
            : Uri.parse(articleUrl).resolveUri(imageUri);
        final host = resolved.host.toLowerCase();
        final imagePath = resolved.path.toLowerCase();
        if (host.contains("google.com") ||
            host.contains("gstatic.com") ||
            host.contains("googleusercontent.com") ||
            imagePath.endsWith(".svg")) {
          continue;
        }
        return resolved.toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

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
  r'''(?:src|srcset|data-src)=["']([^"']+)["']''' ,
  caseSensitive: false,
).firstMatch(description);

String? image = imageMatch?.group(1);

if (image != null && image.startsWith('//')) {
  image = 'https:' + image;
}

if (image != null && !image.startsWith('https://') ) {
  image = null;
}

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

    final visibleNews = news.take(5).toList();

    final enrichedNews = await Future.wait(
      visibleNews.map((item) async {
        if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
          return item;
        }
        final image = await _fetchImage(item.url);
        return EconomyNews(
          title: item.title,
          summary: item.summary,
          source: item.source,
          url: item.url,
          publishedAt: item.publishedAt,
          imageUrl: image,
        );
      }),
    );

    return [...enrichedNews, ...news.skip(5)];
    } catch (_) {
      return [];
    } finally {
      client.close();
    }
  }
}

