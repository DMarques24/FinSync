import 'package:finsync/presentation/pages/analytics/analytics_event.dart';
import 'package:finsync/presentation/pages/analytics/analytics_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc() : super(AnalyticsInitialState()) {}
}
