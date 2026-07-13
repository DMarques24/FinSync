import 'package:finsync/domain/usecases/get_all_desire.dart';
import 'package:finsync/presentation/pages/desire/desire_event.dart';
import 'package:finsync/presentation/pages/desire/desire_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DesireBloc extends Bloc<DesireEvent, DesireState> {
  final GetAllDesire getAllDesire;

  DesireBloc(this.getAllDesire) : super(DesireInitialState()) {
    on<GetAllDesireEvent>(_getAllDesire);
  }

  Future<void> _getAllDesire(
    GetAllDesireEvent event,
    Emitter<DesireState> emit,
  ) async {
    emit(DesireLoadingState());
    try {
      final desire = await getAllDesire();
      emit(DesireLoadedState(desire));
    } catch (e) {
      emit(DesireErrorState(e.toString()));
    }
  }
}
