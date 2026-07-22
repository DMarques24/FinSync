import 'package:flutter/material.dart';

/// Moedas suportadas pela app.
///
/// Importante: isto só troca o símbolo/formato apresentado. A app não faz
/// conversão real de valores entre moedas (isso exigiria taxas de câmbio em
/// tempo real), por isso os números guardados na base de dados não mudam,
/// só a forma como são apresentados.
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

  static String get symbol => type.symbol;
  static String get code => type.code;

  /// Ícone aproximado para a moeda atual (usado em campos de formulário).
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

  /// Formata um valor com o símbolo da moeda atual, respeitando se o
  /// símbolo fica antes (ex: $12.34) ou depois (ex: 12.34 €) do número.
  /// `sign`, se passado (ex: "+ " ou "- "), fica sempre à frente de tudo.
  static String format(num value, {String sign = ''}) {
    final amount = value.abs().toStringAsFixed(2);

    return type.symbolBefore
        ? '$sign${type.symbol}$amount'
        : '$sign$amount ${type.symbol}';
  }
}
