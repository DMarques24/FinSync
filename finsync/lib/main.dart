import 'package:finsync/app/app.dart';
import 'package:finsync/core/di/injection.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://wpyjftcnjwjkzzjokszw.supabase.co",
    publishableKey: "sb_publishable_Z4rKYk-2q9bgVJEDwmLZpg_CWjg-Li7",
  );

  await initDependencies();

  final prefs = await SharedPreferences.getInstance();
  final localeCode = prefs.getString('locale_code');
  final initialLocale = AppLocaleType.values.firstWhere(
    (type) => type.code == localeCode,
    orElse: () => AppLocaleType.pt,
  );
  await AppTranslations.load(initialLocale);

  runApp(const App());
}
