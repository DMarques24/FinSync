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
