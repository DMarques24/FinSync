import 'package:finsync/domain/entities/desire.dart';

abstract class DesireEvent {}

class GetAllDesiresEvent extends DesireEvent {}

class AddDesireEvent extends DesireEvent {
  final Desire desire;

  AddDesireEvent(this.desire);
}
