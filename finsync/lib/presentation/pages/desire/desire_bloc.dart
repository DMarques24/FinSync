import 'package:finsync/core/errors/app_error_translator.dart';
import 'package:finsync/core/notifications/notification_prefs_store.dart';
import 'package:finsync/core/notifications/notification_scheduler.dart';
import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/domain/usecases/add_desire_saving.dart';
import 'package:finsync/domain/usecases/get_all_desires.dart';
import 'package:finsync/domain/usecases/insert_desire.dart';
import 'package:finsync/domain/usecases/register_desire_review.dart';
import 'package:finsync/domain/usecases/upload_desire_image.dart';
import 'package:finsync/presentation/pages/desire/desire_event.dart';
import 'package:finsync/presentation/pages/desire/desire_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DesireBloc extends Bloc<DesireEvent, DesireState> {
  final GetAllDesires getAllDesires;
  final InsertDesire insertDesire;
  final AddDesireSaving addDesireSaving;
  final RegisterDesireReview registerDesireReview;
  final UploadDesireImage uploadDesireImage;

  DesireBloc(
    this.getAllDesires,
    this.insertDesire,
    this.addDesireSaving,
    this.registerDesireReview,
    this.uploadDesireImage,
  ) : super(DesireInitialState()) {
    on<GetAllDesiresEvent>(_getAllDesires);
    on<AddDesireEvent>(_addDesire);
    on<AddDesireSavingEvent>(_addSaving);
    on<ReviewDesireEvent>(_review);
  }

  Future<void> _getAllDesires(
    GetAllDesiresEvent event,
    Emitter<DesireState> emit,
  ) async {
    emit(DesireLoadingState());
    try {
      emit(DesireLoadedState(await getAllDesires()));
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

      final desire = Desire(
        id: event.desire.id,
        name: event.desire.name,
        price: event.desire.price,
        date: event.desire.date,
        image: imageUrl,
        // O valor inicial não entra aqui — entra a seguir, como poupança.
        // Assim gera um movimento em Poupança como qualquer outro depósito;
        // caso contrário seria o único valor a não aparecer no histórico
        // nem nas despesas.
        saved: 0,
        reflection: event.desire.reflection,
        reviewInterval: event.desire.reviewInterval,
      );

      await insertDesire(desire);

      if (event.desire.saved > 0) {
        final created = _findCreated(await getAllDesires(), desire);
        if (created != null) {
          await addDesireSaving(desire: created, amount: event.desire.saved);
        }
      }

      emit(DesireLoadedState(await getAllDesires()));
      event.completer?.complete();
    } catch (e) {
      event.completer?.completeError(e);
      emit(DesireErrorState(AppErrorTranslator.translate(e)));
    }
  }

  Future<void> _addSaving(
    AddDesireSavingEvent event,
    Emitter<DesireState> emit,
  ) async {
    try {
      await addDesireSaving(desire: event.desire, amount: event.amount);

      final desires = await getAllDesires();
      emit(DesireLoadedState(desires));

      await _celebrateIfCompleted(event.desire.id, desires);

      event.completer?.complete();
    } catch (e) {
      // Sem `DesireErrorState` aqui: a lista continua válida e trocá-la por
      // um ecrã de erro por causa de um depósito falhado seria perder o
      // que já estava no ecrã. Quem mostra o erro é a folha que o pediu.
      event.completer?.completeError(e);
    }
  }

  Future<void> _review(
    ReviewDesireEvent event,
    Emitter<DesireState> emit,
  ) async {
    try {
      await registerDesireReview(
        desire: event.desire,
        stillWanted: event.stillWanted,
      );

      emit(DesireLoadedState(await getAllDesires()));
      event.completer?.complete();
    } catch (e) {
      event.completer?.completeError(e);
    }
  }

  /// Avisa quando foi esta poupança a fechar o objetivo.
  ///
  /// Comparar depois de recarregar é o que garante que o aviso sai uma vez
  /// só: um objetivo já completo antes deste depósito não volta a avisar.
  Future<void> _celebrateIfCompleted(
    int desireId,
    List<Desire> desires,
  ) async {
    Desire? updated;
    for (final desire in desires) {
      if (desire.id == desireId) updated = desire;
    }

    if (updated == null || !updated.isComplete) return;

    try {
      final prefs = await NotificationPrefsStore.load();
      await NotificationScheduler.notifyGoalCompleted(
        prefs: prefs,
        desire: updated,
      );
    } catch (_) {
      // Falhar a avisar não pode fazer falhar a poupança, que essa já foi
      // guardada com sucesso.
    }
  }

  /// O `insert` não devolve a linha criada, por isso o id só se conhece
  /// depois de reler a lista. Sem nome único, o mais recente com os mesmos
  /// dados é o melhor que dá para fazer.
  Desire? _findCreated(List<Desire> desires, Desire inserted) {
    final matches = desires.where(
      (desire) =>
          desire.name == inserted.name && desire.price == inserted.price,
    );

    if (matches.isEmpty) return null;

    return matches.reduce((a, b) => a.id >= b.id ? a : b);
  }
}
