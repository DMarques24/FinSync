import 'package:finsync/domain/entities/calendar_event.dart';
import 'package:finsync/domain/usecases/adjust_balance.dart';
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
  final AdjustBalance adjustBalance;
  final DeleteCalendarEvent deleteCalendarEvent;

  AnalyticsBloc(
    this.getAllExpenses,
    this.insertCalendarEvent,
    this.getAllCalendarEvents,
    this.adjustBalance,
    this.deleteCalendarEvent,
  ) : super(AnalyticsInitialState()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
    on<AddEventCalendarEvent>(_addCalendarEvent);
    on<DeleteEventCalendarEvent>(_deleteCalendarEvent);
  }
  Future<void> _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoadingState());

    try {
      final expenses = await getAllExpenses();
      final calendarEvents = await getAllCalendarEvents();

      final nodesById = <String, SankeyNode>{};

      SankeyNode node(String label) => nodesById.putIfAbsent(
        label,
        () => SankeyNode(id: nodesById.length, label: label),
      );

      final links = <SankeyLink>[];

      final byCategory = <String, double>{};

      for (final expense in expenses) {
        byCategory[expense.category] =
            (byCategory[expense.category] ?? 0) + expense.price;
      }

      byCategory.forEach((category, total) {
        links.add(
          SankeyLink(
            source: node("Salário"),
            target: node(category),
            value: total,
          ),
        );
      });

      emit(
        AnalyticsLoadedState(
          nodes: nodesById.values.toList(),
          links: links,
          event: calendarEvents,
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
      await insertCalendarEvent(event.event);
      await adjustBalance(_signedDelta(event.event));

      if (event.event.repeatMonthly) {
        final repeated = CalendarEventEntity(
          id: 0,
          name: event.event.name,
          price: event.event.price,
          date: _addOneMonth(event.event.date),
          type: event.event.type,
          repeatMonthly: true,
        );

        await insertCalendarEvent(repeated);
        await adjustBalance(_signedDelta(repeated));
      }

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
      await deleteCalendarEvent(event.event.id);
      await adjustBalance(-_signedDelta(event.event));

      event.completer?.complete();

      add(LoadAnalyticsEvent());
    } catch (e) {
      event.completer?.completeError(e);
      emit(AnalyticsErrorState(e.toString()));
    }
  }

  /// Receita entra na conta (positivo), despesa sai (negativo).
  double _signedDelta(CalendarEventEntity event) {
    return event.type == CalendarEventType.receita
        ? event.price
        : -event.price;
  }

  /// Avança um mês a partir de [date], ajustando o dia se o mês seguinte
  /// tiver menos dias (ex: 31 de Janeiro -> 28/29 de Fevereiro).
  DateTime _addOneMonth(DateTime date) {
    final year = date.month == 12 ? date.year + 1 : date.year;
    final month = date.month == 12 ? 1 : date.month + 1;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > daysInMonth ? daysInMonth : date.day;
    return DateTime(year, month, day);
  }
}
