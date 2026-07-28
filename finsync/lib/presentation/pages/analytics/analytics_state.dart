import 'package:finsync/domain/entities/calendar_event.dart';
import 'package:finsync/domain/entities/expense.dart';
import 'package:sankey_flutter/sankey_link.dart';
import 'package:sankey_flutter/sankey_node.dart';

abstract class AnalyticsState {}

class AnalyticsInitialState extends AnalyticsState {}

class AnalyticsLoadingState extends AnalyticsState {}

class AnalyticsLoadedState extends AnalyticsState {
  final List<Expense> expenses;
  final List<SankeyNode> nodes;
  final List<SankeyLink> links;
  final List<CalendarEventEntity> events;
  final String topExpenseCategory;

  AnalyticsLoadedState({
    required this.expenses,
    required this.nodes,
    required this.links,
    required this.events,
    required this.topExpenseCategory,
  });
}

class AnalyticsErrorState extends AnalyticsState {
  final String message;

  AnalyticsErrorState(this.message);
}
