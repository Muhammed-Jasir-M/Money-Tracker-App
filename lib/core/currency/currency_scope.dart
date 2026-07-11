import 'package:flutter/material.dart';
import 'package:money_tracker_app/core/constants/currencies.dart';

class CurrencyScope extends InheritedWidget {
  const CurrencyScope({
    super.key,
    required this.symbol,
    required super.child,
  });

  final String symbol;

  static String of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CurrencyScope>();
    return scope?.symbol ?? CurrencyOptions.defaultSymbol;
  }

  @override
  bool updateShouldNotify(CurrencyScope oldWidget) {
    return symbol != oldWidget.symbol;
  }
}
