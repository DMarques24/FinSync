import 'package:finsync/domain/entities/desire.dart';

abstract class DesireState {}

class DesireInitialState extends DesireState {}

class DesireLoadingState extends DesireState {}

class DesireLoadedState extends DesireState {
  final List<Desire> desires;

  DesireLoadedState(this.desires);
}

class DesireErrorState extends DesireState {
  final String message;

  DesireErrorState(this.message);
}
