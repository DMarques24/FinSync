abstract class AnalyticsState {}

class AnalyticsInitialState extends AnalyticsState {}

class AnalyticsLoadingState extends AnalyticsState {}

class AnalyticsLoadedState extends AnalyticsState {}

class AnalyticsErrorState extends AnalyticsState {
  final String message;

  AnalyticsErrorState(this.message);
}
