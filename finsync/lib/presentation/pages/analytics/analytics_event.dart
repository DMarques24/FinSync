import 'dart:async';

import 'package:finsync/domain/entities/calendar_event.dart';

abstract class AnalyticsEvent {}

class LoadAnalyticsEvent extends AnalyticsEvent {}

class AddEventCalendarEvent extends AnalyticsEvent {
  final CalendarEventEntity event;
  final Completer<void>? completer;

  AddEventCalendarEvent(this.event, {this.completer});
}

class DeleteEventCalendarEvent extends AnalyticsEvent {
  final CalendarEventEntity event;

  /// Completa com tudo o que foi removido — numa série é mais do que uma
  /// linha, e o "desfazer" precisa da lista inteira para as repor.
  final Completer<List<CalendarEventEntity>>? completer;

  DeleteEventCalendarEvent(this.event, {this.completer});
}

/// Repõe eventos apagados. Recebe a lista toda para fazer uma única
/// recarga no fim, em vez de uma por evento reposto.
class RestoreEventsCalendarEvent extends AnalyticsEvent {
  final List<CalendarEventEntity> events;
  final Completer<void>? completer;

  RestoreEventsCalendarEvent(this.events, {this.completer});
}

class ExportAnalyticsPdfEvent extends AnalyticsEvent {
  final Completer<String>? completer;

  ExportAnalyticsPdfEvent({this.completer});
}
