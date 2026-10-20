import 'dart:convert';

import 'package:http/http.dart' as http;

/// Indicador econômico com valor e data de referência.
class MarketIndicator {
  final String name;
  final String value;
  final String unit;
  final DateTime referenceDate;

  const MarketIndicator({
    required this.name,
    required this.value,
    required this.unit,
    required this.referenceDate,
  });
}

/// Consulta indicadores econômicos públicos do Banco Central.
///
/// Os dados podem ter atraso conforme a periodicidade de publicação
/// de cada série. Este serviço não representa cotações em tempo real.
class MarketDataService {
  static const String _baseUrl =
      'https://api.bcb.gov.br/dados/serie/bcdata.sgs';

  static final http.Client _client = http.Client();

  static Future<MarketIndicator> _fetchLatest({
    required int series,
    required String name,
    required String unit,
    required String dateFormat,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl.$series/dados/ultimos/1',
    ).replace(
      queryParameters: {
        'formato': 'json',
      },
    );

    final response = await _client
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Não foi possível consultar $name '
        '(HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! List || decoded.isEmpty) {
      throw Exception('Não há dados disponíveis para $name.');
    }

    final entry = decoded.first;

    if (entry is! Map ||
        entry['valor'] == null ||
        entry['data'] == null) {
      throw Exception('Resposta inválida para $name.');
    }

    final rawValue = entry['valor'].toString().trim();
    final rawDate = entry['data'].toString().trim();

    final parsedValue = double.tryParse(
      rawValue.replaceAll(',', '.'),
    );

    if (parsedValue == null) {
      throw Exception('Valor inválido para $name.');
    }

    final parts = rawDate.split('/');

    if (parts.length != 3) {
      throw Exception('Data inválida para $name.');
    }

    final referenceDate = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    final today = DateTime.now();

    if (referenceDate.isAfter(
      DateTime(today.year, today.month, today.day),
    )) {
      throw Exception('Data futura recebida para $name.');
    }

    return MarketIndicator(
      name: name,
      value: _formatValue(parsedValue, dateFormat),
      unit: unit,
      referenceDate: referenceDate,
    );
  }

  static String _formatValue(double value, String format) {
    switch (format) {
      case 'currency':
        return 'R\$ ${value.toStringAsFixed(4).replaceAll('.', ',')}';

      case 'percent':
        return '${value.toStringAsFixed(2).replaceAll('.', ',')}%';

      default:
        return value.toStringAsFixed(2).replaceAll('.', ',');
    }
  }

  /// Meta Selic definida pelo COPOM: série SGS 432.
  static Future<MarketIndicator> fetchSelic() {
    return _fetchLatest(
      series: 432,
      name: 'SELIC',
      unit: 'ao ano',
      dateFormat: 'percent',
    );
  }

  /// Dólar americano — venda, série SGS 1.
  static Future<MarketIndicator> fetchDollar() {
    return _fetchLatest(
      series: 1,
      name: 'DÓLAR',
      unit: 'PTAX diária',
      dateFormat: 'currency',
    );
  }

  /// CDI anualizado, série SGS 4389.
  static Future<MarketIndicator> fetchCdi() {
    return _fetchLatest(
      series: 4389,
      name: 'CDI',
      unit: 'taxa anualizada',
      dateFormat: 'percent',
    );
  }

  /// IPCA acumulado em 12 meses, série SGS 13522.
  static Future<MarketIndicator> fetchIpca() {
    return _fetchLatest(
      series: 13522,
      name: 'IPCA',
      unit: 'acumulado em 12 meses',
      dateFormat: 'percent',
    );
  }

  /// Consulta os indicadores em paralelo.
  ///
  /// Se uma consulta falhar, as demais ainda poderão ser utilizadas.
  static Future<List<MarketIndicator>> fetchAll() async {
    final results = await Future.wait([
      _fetchSafely(fetchSelic),
      _fetchSafely(fetchDollar),
      _fetchSafely(fetchCdi),
      _fetchSafely(fetchIpca),
    ]);

    return results.whereType<MarketIndicator>().toList();
  }

  static Future<MarketIndicator?> _fetchSafely(
    Future<MarketIndicator> Function() fetch,
  ) async {
    try {
      return await fetch();
    } catch (_) {
      return null;
    }
  }
}
