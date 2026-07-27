import 'dart:convert';

import 'package:finsync/core/locale/app_locale.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppTranslations {
  AppTranslations._();

  static Map<String, String> _strings = {};
  static AppLocaleType current = AppLocaleType.pt;

  static Future<void> load(AppLocaleType locale) async {
    final raw = await rootBundle.loadString('assets/i18n/${locale.code}.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _strings = _flatten(decoded);
    current = locale;
  }

  static Map<String, String> _flatten(
    Map<String, dynamic> map, [
    String prefix = '',
  ]) {
    final result = <String, String>{};
    map.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        result.addAll(_flatten(value, fullKey));
      } else {
        result[fullKey] = value.toString();
      }
    });
    return result;
  }

  static String t(String key, [Map<String, String>? params]) {
    var value = _strings[key] ?? key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }
    return value;
  }
}

String tr(String key, [Map<String, String>? params]) =>
    AppTranslations.t(key, params);
