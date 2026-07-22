import 'dart:async';

import 'package:finsync/domain/entities/calendar_event.dart';

abstract class AnalyticsEvent {}

class LoadAnalyticsEvent extends AnalyticsEvent {}

class AddEventCalendarEvent extends AnalyticsEvent {
  final CalendarEventEntity event;
  final Completer<void>? completer;

  AddEventCalendarEvent(this.event, {this.completer});
}
