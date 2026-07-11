class MoneyFormat {
  MoneyFormat._();

  static String amount(
    double value,
    String symbol, {
    int decimals = 2,
    bool withSpace = false,
  }) {
    final spacer = withSpace ? ' ' : '';
    return '$symbol$spacer${value.toStringAsFixed(decimals)}';
  }

  static String signed(
    double value,
    String symbol, {
    required bool isIncome,
    int decimals = 2,
  }) {
    final prefix = isIncome ? '+' : '-';
    return '$prefix$symbol${value.toStringAsFixed(decimals)}';
  }

  static String compact(double value, String symbol) {
    if (value >= 1000000) {
      final millions = value / 1000000;
      final text = millions == millions.roundToDouble()
          ? millions.toInt().toString()
          : millions.toStringAsFixed(1);
      return '$symbol${text}M';
    }
    if (value >= 1000) {
      final thousands = value / 1000;
      final text = thousands == thousands.roundToDouble()
          ? thousands.toInt().toString()
          : thousands.toStringAsFixed(1);
      return '$symbol${text}K';
    }
    return '$symbol${value.round()}';
  }
}
