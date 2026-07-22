import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/theme_event.dart';
import 'package:finsync/core/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const _prefsKey = 'theme_mode';

  ThemeBloc() : super(const ThemeState(ThemeMode.system)) {
    on<LoadThemeEvent>(_onLoad);
    on<ChangeThemeEvent>(_onChange);
  }

  Future<void> _onLoad(LoadThemeEvent event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final mode = _modeFromString(prefs.getString(_prefsKey));

    _syncAppColors(mode);
    emit(ThemeState(mode));
  }

  Future<void> _onChange(
    ChangeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, event.mode.name);

    _syncAppColors(event.mode);
    emit(ThemeState(event.mode));
  }

  ThemeMode _modeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }


  void _syncAppColors(ThemeMode mode) {
    final bool isDark;
    switch (mode) {
      case ThemeMode.dark:
        isDark = true;
        break;
      case ThemeMode.light:
        isDark = false;
        break;
      case ThemeMode.system:
        isDark =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
        break;
    }
    AppColors.isDark = isDark;
  }
}
