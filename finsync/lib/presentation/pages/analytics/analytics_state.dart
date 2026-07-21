import 'package:sankey_flutter/sankey_link.dart';
import 'package:sankey_flutter/sankey_node.dart';

abstract class AnalyticsState {}

class AnalyticsInitialState extends AnalyticsState {}

class AnalyticsLoadingState extends AnalyticsState {}

class AnalyticsLoadedState extends AnalyticsState {
  final List<SankeyNode> nodes;
  final List<SankeyLink> links;

  AnalyticsLoadedState({required this.nodes, required this.links});
}

class AnalyticsErrorState extends AnalyticsState {
  final String message;

  AnalyticsErrorState(this.message);
}
