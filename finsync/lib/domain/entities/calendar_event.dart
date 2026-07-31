import 'dart:math';

import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/entities/expense_category.dart';

enum CalendarEventType { despesa, receita }

/// Um evento é um movimento **agendado**, não um movimento.
///
/// Enquanto a data não chega, é só um lembrete: não mexe no saldo nem
/// aparece nas receitas ou despesas. No dia marcado é lançado como um
/// movimento normal na tabela `expenses` e `appliedAt` fica preenchido,
/// para nunca ser lançado duas vezes.
class CalendarEventEntity {
  final int id;
  final String name;
  final double price;
  final DateTime date;
  final CalendarEventType type;

  /// Mesma regra das despesas: um evento de despesa tem categoria própria,
  /// um de receita fica sempre em `rendimento`.
  final ExpenseCategory category;

  final bool repeatMonthly;

  /// Quando foi lançado como movimento. `null` = ainda por lançar.
  final DateTime? appliedAt;

  /// Identificador partilhado por todas as repetições do mesmo evento.
  ///
  /// Um evento repetido não é uma linha, são várias — uma por mês. Sem esta
  /// referência não havia forma de saber que a renda de março e a de abril
  /// são a mesma coisa, e apagar uma deixava as outras órfãs.
  /// `null` num evento que não se repete.
  final String? seriesId;

  CalendarEventEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.date,
    this.type = CalendarEventType.despesa,
    this.category = ExpenseCategory.lazer,
    this.repeatMonthly = false,
    this.appliedAt,
    this.seriesId,
  });

  bool get isApplied => appliedAt != null;

  bool get isPartOfSeries => seriesId != null;

  CalendarEventEntity copyWith({
    int? id,
    DateTime? date,
    DateTime? appliedAt,
    String? seriesId,
    bool? repeatMonthly,
  }) {
    return CalendarEventEntity(
      id: id ?? this.id,
      name: name,
      price: price,
      date: date ?? this.date,
      type: type,
      category: category,
      repeatMonthly: repeatMonthly ?? this.repeatMonthly,
      appliedAt: appliedAt ?? this.appliedAt,
      seriesId: seriesId ?? this.seriesId,
    );
  }

  /// UUID v4 gerado localmente. Ambas as repetições têm de nascer com o
  /// mesmo valor, por isso não pode vir da base de dados — teria de ser
  /// pedido primeiro e só depois usado na segunda inserção.
  static String newSeriesId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    bytes[6] = (bytes[6] & 0x0f) | 0x40; // versão 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variante RFC 4122

    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  /// Já chegou o dia? Comparamos por dia civil, não por instante: um evento
  /// marcado para hoje conta hoje, mesmo que tenha sido criado às 23h.
  bool isDueOn(DateTime reference) {
    final eventDay = DateTime(date.year, date.month, date.day);
    final referenceDay = DateTime(
      reference.year,
      reference.month,
      reference.day,
    );
    return !eventDay.isAfter(referenceDay);
  }

  ExpenseType get expenseType => type == CalendarEventType.receita
      ? ExpenseType.receita
      : ExpenseType.despesa;

  /// O movimento que este evento se torna quando o dia chega.
  Expense toExpense() {
    return Expense(
      id: 0,
      name: name,
      price: price,
      category: category,
      date: date,
      type: expenseType,
    );
  }
}
