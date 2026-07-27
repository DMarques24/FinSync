import 'package:finsync/core/locale/app_locale.dart';

abstract class LocaleEvent {}

class LoadLocaleEvent extends LocaleEvent {}

class ChangeLocaleEvent extends LocaleEvent {
  final AppLocaleType type;

  ChangeLocaleEvent(this.type);
}
