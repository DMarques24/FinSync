import 'package:finsync/domain/usecases/get_all_desires.dart';
import 'package:finsync/domain/usecases/insert_desire.dart';
import 'package:finsync/presentation/pages/desire/desire_event.dart';
import 'package:finsync/presentation/pages/desire/desire_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DesireBloc extends Bloc<DesireEvent, DesireState> {
  final GetAllDesires getAllDesires;
  final InsertDesire insertDesire;

  DesireBloc(this.getAllDesires, this.insertDesire)
    : super(DesireInitialState()) {
    on<GetAllDesiresEvent>(_getAllDesires);
    on<AddDesireEvent>(_addDesire);
  }

  Future<void> _getAllDesires(
    GetAllDesiresEvent event,
    Emitter<DesireState> emit,
  ) async {
    emit(DesireLoadingState());
    try {
      final desire = await getAllDesires();
      emit(DesireLoadedState(desire));
    } catch (e) {
      emit(DesireErrorState(e.toString()));
    }
  }

  Future<void> _addDesire(
    AddDesireEvent event,
    Emitter<DesireState> emit,
  ) async {
    try {
      await insertDesire(event.desire);
      final desire = await getAllDesires();
      emit(DesireLoadedState(desire));
    } catch (e) {
      emit(DesireErrorState(e.toString()));
    }
  }
}
