import 'package:flutter/material.dart';

enum AppCurrencyType {
  eur('EUR', '€', 'Euro', false),
  usd('USD', '\$', 'Dólar Americano', true),
  gbp('GBP', '£', 'Libra Esterlina', true),
  brl('BRL', 'R\$', 'Real Brasileiro', true);

  final String code;
  final String symbol;
  final String label;
  final bool symbolBefore;

  const AppCurrencyType(this.code, this.symbol, this.label, this.symbolBefore);
}

class AppCurrency {
  AppCurrency._();

  static AppCurrencyType type = AppCurrencyType.eur;
  static Map<String, double> _ratesFromEur = const {'EUR': 1.0};

  static void updateRates(Map<String, double> rates) {
    _ratesFromEur = rates;
  }

  static double get _rate => _ratesFromEur[type.code] ?? 1.0;

  static double convert(num valueInEur) => valueInEur * _rate;

  static double toBase(num valueInSelectedCurrency) =>
      _rate == 0 ? 0 : valueInSelectedCurrency / _rate;

  static String get symbol => type.symbol;
  static String get code => type.code;

  static IconData get icon {
    switch (type) {
      case AppCurrencyType.eur:
        return Icons.euro_rounded;
      case AppCurrencyType.usd:
        return Icons.attach_money_rounded;
      case AppCurrencyType.gbp:
        return Icons.currency_pound_rounded;
      case AppCurrencyType.brl:
        return Icons.attach_money_rounded;
    }
  }

  static String format(num valueInEur, {String sign = ''}) {
    final amount = convert(valueInEur).abs().toStringAsFixed(2);

    return type.symbolBefore
        ? '$sign${type.symbol}$amount'
        : '$sign$amount ${type.symbol}';
  }
}
