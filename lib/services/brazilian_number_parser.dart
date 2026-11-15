class BrazilianNumberParser {
  BrazilianNumberParser._();

  static double? parse(String input, {bool dotIsDecimal = false}) {
    var value = input
        .trim()
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('\u00A0', '')
        .replaceAll('\u202F', '');

    if (value.isEmpty) return null;

    var negative = false;

    if (value.startsWith('(') && value.endsWith(')')) {
      negative = true;
      value = value.substring(1, value.length - 1);
    }

    if (value.startsWith('-')) {
      negative = !negative;
      value = value.substring(1);
    } else if (value.startsWith('+')) {
      value = value.substring(1);
    }

    value = value.replaceAll(RegExp(r'[^0-9.,]'), '');

    if (value.isEmpty) return null;

    if (value.contains(',') && value.contains('.')) {
      // Padrão brasileiro: 60.000,00
      value = value.replaceAll('.', '').replaceAll(',', '.');
    } else if (value.contains(',')) {
      // Vírgula como separador decimal: 60000,00
      value = value.replaceAll(',', '.');
    } else if (value.contains('.') && !dotIsDecimal) {
      // Ponto como separador de milhar: 60.000 ou 1.234.567
      if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(value)) {
        value = value.replaceAll('.', '');
      }
    }

    final result = double.tryParse(value);
    if (result == null || !result.isFinite) return null;

    return negative ? -result : result;
  }
}
