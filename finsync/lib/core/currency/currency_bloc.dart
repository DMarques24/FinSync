import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/currency/currency_event.dart';
import 'package:finsync/core/currency/currency_state.dart';
import 'package:finsync/core/currency/exchange_rate_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  static const _prefsKey = 'currency_code';

  CurrencyBloc() : super(const CurrencyState(AppCurrencyType.eur)) {
    on<LoadCurrencyEvent>(_onLoad);
    on<ChangeCurrencyEvent>(_onChange);
  }

  Future<void> _onLoad(
    LoadCurrencyEvent event,
    Emitter<CurrencyState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final type = _typeFromCode(prefs.getString(_prefsKey));

    AppCurrency.type = type;
    AppCurrency.updateRates(await ExchangeRateService.getRates());
    emit(CurrencyState(type));
  }

  Future<void> _onChange(
    ChangeCurrencyEvent event,
    Emitter<CurrencyState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, event.type.code);

    AppCurrency.type = event.type;
    AppCurrency.updateRates(await ExchangeRateService.getRates());
    emit(CurrencyState(event.type));
  }

  AppCurrencyType _typeFromCode(String? code) {
    return AppCurrencyType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => AppCurrencyType.eur,
    );
  }
}
