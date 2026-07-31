import 'package:finsync/data/datasources/expense_remote_datasource.dart'
    show kAnalyticsExpensesLimit;
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/domain/entities/calendar_event.dart';
import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/entities/expense_category.dart';
import 'package:finsync/presentation/pages/home/components/category_labels.dart';
import 'package:finsync/domain/usecases/apply_due_calendar_events.dart';
import 'package:finsync/domain/usecases/create_analytics_pdf.dart';
import 'package:finsync/domain/usecases/delete_calendar_event.dart';
import 'package:finsync/domain/usecases/get_all_calendar_events.dart';
import 'package:finsync/domain/usecases/get_all_expenses.dart';
import 'package:finsync/domain/usecases/insert_calendar_event.dart';
import 'package:finsync/presentation/pages/analytics/analytics_event.dart';
import 'package:finsync/presentation/pages/analytics/analytics_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sankey_flutter/sankey_link.dart';
import 'package:sankey_flutter/sankey_node.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetAllExpenses getAllExpenses;
  final InsertCalendarEvent insertCalendarEvent;
  final GetAllCalendarEvents getAllCalendarEvents;
  final ApplyDueCalendarEvents applyDueCalendarEvents;
  final DeleteCalendarEvent deleteCalendarEvent;
  final CreateAnalyticsPdf createAnalyticsPdf;

  AnalyticsBloc(
    this.getAllExpenses,
    this.insertCalendarEvent,
    this.getAllCalendarEvents,
    this.applyDueCalendarEvents,
    this.deleteCalendarEvent,
    this.createAnalyticsPdf,
  ) : super(AnalyticsInitialState()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
    on<AddEventCalendarEvent>(_addCalendarEvent);
    on<DeleteEventCalendarEvent>(_deleteCalendarEvent);
    on<RestoreEventsCalendarEvent>(_restoreCalendarEvents);
    on<ExportAnalyticsPdfEvent>(_exportAnalyticsPdf);
  }
  Future<void> _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoadingState());

    try {
      // Antes de ler seja o que for: lança os eventos cujo dia já chegou,
      // para que apareçam já como movimentos nos números abaixo.
      await applyDueCalendarEvents();

      final expenses = await getAllExpenses(limit: kAnalyticsExpensesLimit);
      final calendarEvents = await getAllCalendarEvents();

      final nodesById = <String, SankeyNode>{};

      SankeyNode node(String label) => nodesById.putIfAbsent(
        label,
        () => SankeyNode(id: nodesById.length, label: label),
      );

      final links = <SankeyLink>[];

      final byCategory = <ExpenseCategory, double>{};

      for (final expense in expenses) {
        // Só despesas. As receitas entram todas na categoria `rendimento`
        // e, se contassem aqui, apareciam como um gasto no fluxo e podiam
        // até ser eleitas "categoria com maior gasto".
        if (expense.type != ExpenseType.despesa) continue;

        byCategory[expense.category] =
            (byCategory[expense.category] ?? 0) + expense.price;
      }

      byCategory.forEach((category, total) {
        links.add(
          SankeyLink(
            source: node("Salário"),
            target: node(categoryLabel(category)),
            value: total,
          ),
        );
      });

      var topExpenseCategory = tr('analytics.no_expenses_recorded');
      if (byCategory.isNotEmpty) {
        final topEntry = byCategory.entries.reduce(
          (a, b) => a.value >= b.value ? a : b,
        );
        topExpenseCategory = categoryLabel(topEntry.key);
      }

      emit(
        AnalyticsLoadedState(
          expenses: expenses,
          nodes: nodesById.values.toList(),
          links: links,
          events: calendarEvents,
          topExpenseCategory: topExpenseCategory,
        ),
      );
    } catch (e) {
      emit(AnalyticsErrorState(e.toString()));
    }
  }

  Future<void> _addCalendarEvent(
    AddEventCalendarEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      // Repara que não há ajuste de saldo aqui. Um evento é um lembrete
      // até ao dia marcado; o saldo só mexe quando o
      // `ApplyDueCalendarEvents` o transformar num movimento.
      if (!event.event.repeatMonthly) {
        await insertCalendarEvent(event.event);
        event.completer?.complete();
        add(LoadAnalyticsEvent());
        return;
      }

      // As duas repetições nascem com o mesmo `seriesId`. É esse valor que
      // permite, mais tarde, apagá-las como um todo.
      final seriesId = CalendarEventEntity.newSeriesId();

      await insertCalendarEvent(event.event.copyWith(seriesId: seriesId));
      await insertCalendarEvent(
        event.event.copyWith(
          date: _addOneMonth(event.event.date),
          seriesId: seriesId,
        ),
      );

      event.completer?.complete();

      add(LoadAnalyticsEvent());
    } catch (e) {
      event.completer?.completeError(e);
      emit(AnalyticsErrorState(e.toString()));
    }
  }

  Future<void> _deleteCalendarEvent(
    DeleteEventCalendarEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      // Guardado antes de apagar, senão o "desfazer" não tinha o que repor.
      final removed = _eventsInSameSeries(event.event);

      // Apagar um evento já lançado remove só o lembrete: o movimento que
      // ele gerou fica, porque a despesa aconteceu mesmo. Se ainda não
      // tinha sido lançado, não há nada a desfazer no saldo.
      await deleteCalendarEvent(event.event);

      event.completer?.complete(removed);

      add(LoadAnalyticsEvent());
    } catch (e) {
      event.completer?.completeError(e);
      emit(AnalyticsErrorState(e.toString()));
    }
  }

  Future<void> _restoreCalendarEvents(
    RestoreEventsCalendarEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      // Repostos tal e qual estavam, incluindo `seriesId` e `appliedAt`:
      // continuam a ser a mesma série e os que já tinham sido lançados não
      // voltam a gerar movimento. Os ids são novos, esses perderam-se com
      // o DELETE.
      for (final removed in event.events) {
        await insertCalendarEvent(removed);
      }

      event.completer?.complete();

      add(LoadAnalyticsEvent());
    } catch (e) {
      event.completer?.completeError(e);
      emit(AnalyticsErrorState(e.toString()));
    }
  }

  /// Todas as repetições da mesma série que estejam no estado atual.
  /// Num evento solto devolve só o próprio.
  List<CalendarEventEntity> _eventsInSameSeries(CalendarEventEntity event) {
    final current = state;
    final seriesId = event.seriesId;

    if (seriesId == null || current is! AnalyticsLoadedState) return [event];

    final siblings = current.events
        .where((other) => other.seriesId == seriesId)
        .toList();

    return siblings.isEmpty ? [event] : siblings;
  }

  Future<void> _exportAnalyticsPdf(
    ExportAnalyticsPdfEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final path = await createAnalyticsPdf();
      event.completer?.complete(path);
    } catch (e) {
      event.completer?.completeError(e);
    }
  }

  DateTime _addOneMonth(DateTime date) {
    final year = date.month == 12 ? date.year + 1 : date.year;
    final month = date.month == 12 ? 1 : date.month + 1;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > daysInMonth ? daysInMonth : date.day;
    return DateTime(year, month, day);
  }
}
