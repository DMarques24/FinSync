import 'package:finsync/data/datasources/pdf_remote_datasource.dart';
import 'package:finsync/data/models/pdf_category_total_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PdfRemoteDatasourceImpl implements PdfRemoteDatasource {
  final supabase = Supabase.instance.client;

  String get userId {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Utilizador não autenticado para exportar PDF.');
    }
    return user.id;
  }

  @override
  Future<PdfAnalyticsPayload> fetchAnalyticsPayload({
    DateTime? referenceDate,
    int upcomingEventsLimit = 10,
    String appName = 'FinSync',
  }) async {
    final now = referenceDate ?? DateTime.now();

    final profileFuture = supabase
        .from('profiles')
        .select('balance')
        .eq('user_id', userId)
        .maybeSingle();

    final expensesFuture = supabase
        .from('expenses')
        .select('price, category, type')
        .eq('user_id', userId);

    final upcomingEventsFuture = supabase
        .from('calendar_events')
        .select('name, price, event_date, type')
        .eq('user_id', userId)
        .gte(
          'event_date',
          DateTime(now.year, now.month, now.day).toIso8601String(),
        )
        .order('event_date', ascending: true)
        .limit(upcomingEventsLimit);

    final responses = await Future.wait<dynamic>([
      profileFuture,
      expensesFuture,
      upcomingEventsFuture,
    ]);

    final profile = responses[0] as Map<String, dynamic>?;
    final expenses = (responses[1] as List).cast<Map<String, dynamic>>();
    final events = (responses[2] as List).cast<Map<String, dynamic>>();

    final currentBalance = _toDouble(profile?['balance']);

    var totalIncome = 0.0;
    var totalExpense = 0.0;
    final byCategory = <String, double>{};

    for (final expense in expenses) {
      final value = _toDouble(expense['price']);
      final type = expense['type']?.toString() ?? '';

      if (type == 'receita') {
        totalIncome += value;
      } else {
        totalExpense += value;
        final category =
            (expense['category']?.toString().trim().isNotEmpty ?? false)
            ? expense['category'].toString().trim()
            : 'Sem categoria';
        byCategory[category] = (byCategory[category] ?? 0) + value;
      }
    }

    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topExpenseCategory = sortedCategories.isEmpty
        ? 'Sem despesas registadas'
        : sortedCategories.first.key;

    final pieByCategory = sortedCategories
        .map(
          (entry) => PdfCategoryTotal(category: entry.key, total: entry.value),
        )
        .toList();

    final sankeyLinks = sortedCategories
        .map(
          (entry) => PdfSankeyLinkData(
            source: 'Receitas',
            target: entry.key,
            value: entry.value,
          ),
        )
        .toList();

    final upcomingEvents = events.map((event) {
      final rawDate = event['event_date'];
      final parsedDate = rawDate is DateTime
          ? rawDate
          : DateTime.tryParse(rawDate?.toString() ?? '') ?? now;

      return PdfUpcomingEventData(
        name: event['name']?.toString() ?? '',
        price: _toDouble(event['price']),
        date: parsedDate,
        type: event['type']?.toString() ?? 'despesa',
      );
    }).toList();

    return PdfAnalyticsPayload(
      appName: appName,
      generatedAt: now,
      currentBalance: currentBalance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      topExpenseCategory: topExpenseCategory,
      pieByCategory: pieByCategory,
      sankeyLinks: sankeyLinks,
      upcomingEvents: upcomingEvents,
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Future<PdfAnalyticsPayload> getDataPayload() {
    // TODO: implement getDataPayload
    throw UnimplementedError();
  }
}
