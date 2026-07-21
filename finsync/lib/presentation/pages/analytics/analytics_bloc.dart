import 'package:finsync/domain/usecases/get_all_desires.dart';
import 'package:finsync/domain/usecases/get_all_expenses.dart';
import 'package:finsync/presentation/pages/analytics/analytics_event.dart';
import 'package:finsync/presentation/pages/analytics/analytics_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sankey_flutter/sankey_link.dart';
import 'package:sankey_flutter/sankey_node.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetAllExpenses getAllExpenses;
  final GetAllDesires getAllDesires;
  AnalyticsBloc(this.getAllExpenses, this.getAllDesires)
    : super(AnalyticsInitialState()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
  }
  Future<void> _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoadingState());
    try {
      final expenses = await getAllExpenses();
      final desires = await getAllDesires();

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
            source: node('Salário'),
            target: node(category),
            value: total,
          ),
        );
      });

      final desiresTotal = desires.fold<double>(0, (sum, d) => sum + d.price);
      if (desiresTotal > 0) {
        links.add(
          SankeyLink(
            source: node('Salário'),
            target: node('Objetivos'),
            value: desiresTotal,
          ),
        );
      }

      emit(
        AnalyticsLoadedState(nodes: nodesById.values.toList(), links: links),
      );
    } catch (e) {
      emit(AnalyticsErrorState(e.toString()));
    }
  }
}
