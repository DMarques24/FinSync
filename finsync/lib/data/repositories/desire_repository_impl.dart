import 'dart:io';

import 'package:finsync/data/datasources/desire_remote_datasource.dart';
import 'package:finsync/data/models/desire_model.dart';
import 'package:finsync/data/models/desire_saving_model.dart';
import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/domain/entities/desire_review.dart';
import 'package:finsync/domain/entities/desire_saving.dart';
import 'package:finsync/domain/repositories/desire_repository.dart';

class DesireRepositoryImpl implements DesireRepository {
  final DesireRemoteDatasource remoteDatasource;

  DesireRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Desire>> getAllDesires() async {
    final models = await remoteDatasource.getAllDesires();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> insertDesire(Desire desire) async {
    await remoteDatasource.insertDesire(DesireModel.fromEntity(desire));
  }

  @override
  Future<String> uploadImage(File file) async {
    return await remoteDatasource.uploadImage(file);
  }

  @override
  Future<void> addSaving({
    required int desireId,
    required double amount,
  }) async {
    await remoteDatasource.insertDesireSaving(
      DesireSavingModel(
        id: 0,
        desireId: desireId,
        amount: amount,
        date: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<DesireSaving>> getSavings(int desireId) async {
    final models = await remoteDatasource.getDesireSavings(desireId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> registerReview(Desire desire, DesireReview review) async {
    final reviews = [...desire.reviews, review];

    await remoteDatasource.updateDesireReviews(
      desire.id,
      reviews.map((entry) => entry.toJson()).toList(),
      review.at,
    );
  }
}
