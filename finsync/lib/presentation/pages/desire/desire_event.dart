import 'dart:async';
import 'dart:io';

import 'package:finsync/domain/entities/desire.dart';

abstract class DesireEvent {}

class GetAllDesiresEvent extends DesireEvent {}

class AddDesireEvent extends DesireEvent {
  final Desire desire;
  final File? imageFile;
  final Completer<void>? completer;

  AddDesireEvent(this.desire, {this.imageFile, this.completer});
}

/// Guardar dinheiro para um desejo.
class AddDesireSavingEvent extends DesireEvent {
  final Desire desire;
  final double amount;
  final Completer<void>? completer;

  AddDesireSavingEvent(this.desire, this.amount, {this.completer});
}

/// Resposta à pergunta periódica "isto ainda faz sentido?".
class ReviewDesireEvent extends DesireEvent {
  final Desire desire;
  final bool stillWanted;
  final Completer<void>? completer;

  ReviewDesireEvent(this.desire, this.stillWanted, {this.completer});
}
