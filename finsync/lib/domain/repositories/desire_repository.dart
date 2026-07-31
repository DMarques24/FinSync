import 'dart:io';

import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/domain/entities/desire_review.dart';
import 'package:finsync/domain/entities/desire_saving.dart';

abstract class DesireRepository {
  Future<List<Desire>> getAllDesires();

  Future<void> insertDesire(Desire desire);

  Future<String> uploadImage(File file);

  Future<void> addSaving({required int desireId, required double amount});

  Future<List<DesireSaving>> getSavings(int desireId);

  Future<void> registerReview(Desire desire, DesireReview review);
}
