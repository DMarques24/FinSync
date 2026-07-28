import 'package:finsync/core/errors/app_error_translator.dart';
import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/domain/usecases/adjust_balance.dart';
import 'package:finsync/domain/usecases/get_all_desires.dart';
import 'package:finsync/domain/usecases/insert_desire.dart';
import 'package:finsync/domain/usecases/upload_desire_image.dart';
import 'package:finsync/presentation/pages/desire/desire_event.dart';
import 'package:finsync/presentation/pages/desire/desire_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DesireBloc extends Bloc<DesireEvent, DesireState> {
  final GetAllDesires getAllDesires;
  final InsertDesire insertDesire;
  final AdjustBalance adjustBalance;
  final UploadDesireImage uploadDesireImage;

  DesireBloc(
    this.getAllDesires,
    this.insertDesire,
    this.adjustBalance,
    this.uploadDesireImage,
  ) : super(DesireInitialState()) {
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
      emit(DesireErrorState(AppErrorTranslator.translate(e)));
    }
  }

  Future<void> _addDesire(
    AddDesireEvent event,
    Emitter<DesireState> emit,
  ) async {
    try {
      String? imageUrl = event.desire.image;
      if (event.imageFile != null) {
        imageUrl = await uploadDesireImage(event.imageFile!);
      }

      final desireToInsert = Desire(
        id: event.desire.id,
        name: event.desire.name,
        price: event.desire.price,
        date: event.desire.date,
        image: imageUrl,
        saved: event.desire.saved,
      );

      await insertDesire(desireToInsert);

      if (event.desire.saved > 0) {
        await adjustBalance(-event.desire.saved);
      }

      final desire = await getAllDesires();
      emit(DesireLoadedState(desire));

      event.completer?.complete();
    } catch (e) {
      event.completer?.completeError(e);
      emit(DesireErrorState(AppErrorTranslator.translate(e)));
    }
  }
}
