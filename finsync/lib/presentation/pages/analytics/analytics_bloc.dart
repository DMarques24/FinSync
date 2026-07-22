import 'package:finsync/domain/entities/calendar_event.dart';
import 'package:finsync/domain/usecases/adjust_balance.dart';
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

  AnalyticsBloc(
    this.getAllExpenses,
    this.insertCalendarEvent,
    this.getAllCalendarEvents,
    this.adjustBalance,
  ) : super(AnalyticsInitialState()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
    on<AddEventCalendarEvent>(_addCalendarEvent);
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

      final delta = event.event.type == CalendarEventType.receita
          ? event.event.price
          : -event.event.price;
      await adjustBalance(delta);

      event.completer?.complete();

      add(LoadAnalyticsEvent());
    } catch (e) {
      event.completer?.completeError(e);
      emit(AnalyticsErrorState(e.toString()));
    }
  }
}
