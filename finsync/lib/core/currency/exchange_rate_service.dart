import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRateService {
  ExchangeRateService._();

  static const _ratesKey = 'exchange_rates_eur';
  static const _updatedAtKey = 'exchange_rates_updated_at';
  static const _cacheTtl = Duration(hours: 12);
  static const _endpoint = 'https://open.er-api.com/v6/latest/EUR';

  static const Map<String, double> _fallbackRates = {
    'EUR': 1.0,
    'USD': 1.08,
    'GBP': 0.86,
    'BRL': 5.80,
  };

  static Future<Map<String, double>> getRates({
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = _readCache(prefs);
      if (cached != null) return cached;
    }

    try {
      final fresh = await _fetchFromApi();
      await _writeCache(prefs, fresh);
      return fresh;
    } catch (_) {
      return _readCache(prefs, ignoreTtl: true) ?? _fallbackRates;
    }
  }

  static Map<String, double>? _readCache(
    SharedPreferences prefs, {
    bool ignoreTtl = false,
  }) {
    final raw = prefs.getString(_ratesKey);
    final updatedAtMillis = prefs.getInt(_updatedAtKey);
    if (raw == null || updatedAtMillis == null) return null;

    if (!ignoreTtl) {
      final updatedAt = DateTime.fromMillisecondsSinceEpoch(updatedAtMillis);
      if (DateTime.now().difference(updatedAt) > _cacheTtl) return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((code, value) => MapEntry(code, (value as num).toDouble()));
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writeCache(
    SharedPreferences prefs,
    Map<String, double> rates,
  ) async {
    await prefs.setString(_ratesKey, jsonEncode(rates));
    await prefs.setInt(_updatedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<Map<String, double>> _fetchFromApi() async {
    final response = await http
        .get(Uri.parse(_endpoint))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Falha ao obter taxas de câmbio (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['result'] != 'success') {
      throw Exception('Resposta inválida da API de câmbio.');
    }

    final rates = body['rates'] as Map<String, dynamic>;
    return rates.map((code, value) => MapEntry(code, (value as num).toDouble()));
  }
}
