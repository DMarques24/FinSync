import 'package:finsync/domain/entities/desire.dart' as desire_entity;

abstract class DesireState {}

class DesireInitialState extends DesireState {}

class DesireLoadingState extends DesireState {}

class DesireLoadedState extends DesireState {
  final List<desire_entity.Desire> desire;

  DesireLoadedState(this.desire);
}

class DesireErrorState extends DesireState {
  final String message;

  DesireErrorState(this.message);
}
