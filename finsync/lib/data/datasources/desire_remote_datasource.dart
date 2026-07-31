import 'dart:io';

import 'package:finsync/data/models/desire_model.dart';
import 'package:finsync/data/models/desire_saving_model.dart';

abstract class DesireRemoteDatasource {
  Future<List<DesireModel>> getAllDesires();

  Future<void> insertDesire(DesireModel desire);

  Future<String> uploadImage(File file);

  /// Regista uma poupança e soma-a ao total do desejo.
  Future<void> insertDesireSaving(DesireSavingModel saving);

  Future<List<DesireSavingModel>> getDesireSavings(int desireId);

  /// Guarda a resposta a uma reavaliação e reinicia o contador.
  Future<void> updateDesireReviews(
    int desireId,
    List<Map<String, dynamic>> reviews,
    DateTime reviewedAt,
  );
}
