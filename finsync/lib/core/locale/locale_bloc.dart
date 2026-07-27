import 'package:finsync/core/locale/app_locale.dart';
import 'package:finsync/core/locale/locale_event.dart';
import 'package:finsync/core/locale/locale_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const _prefsKey = 'locale_code';

  LocaleBloc() : super(const LocaleState(AppLocaleType.pt)) {
    on<LoadLocaleEvent>(_onLoad);
    on<ChangeLocaleEvent>(_onChange);
  }

  Future<void> _onLoad(LoadLocaleEvent event, Emitter<LocaleState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final type = _typeFromCode(prefs.getString(_prefsKey));
    emit(LocaleState(type));
  }

  Future<void> _onChange(
    ChangeLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, event.type.code);
    emit(LocaleState(event.type));
  }

  AppLocaleType _typeFromCode(String? code) {
    return AppLocaleType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => AppLocaleType.pt,
    );
  }
}
