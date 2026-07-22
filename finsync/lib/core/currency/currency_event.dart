import 'package:finsync/core/currency/app_currency.dart';

abstract class CurrencyEvent {}

class LoadCurrencyEvent extends CurrencyEvent {}

class ChangeCurrencyEvent extends CurrencyEvent {
  final AppCurrencyType type;

  ChangeCurrencyEvent(this.type);
}
