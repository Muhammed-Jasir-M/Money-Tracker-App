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
      return '$symbol${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '$symbol${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${value.toStringAsFixed(0)}';
  }
}
