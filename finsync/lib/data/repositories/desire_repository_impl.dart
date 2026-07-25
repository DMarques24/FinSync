import 'dart:io';

import 'package:finsync/data/datasources/desire_remote_datasource.dart';
import 'package:finsync/data/models/desire_model.dart';
import 'package:finsync/domain/entities/desire.dart';
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
    final model = DesireModel(
      id: desire.id,
      name: desire.name,
      price: desire.price,
      date: desire.date,
      image: desire.image,
      saved: desire.saved,
    );
    await remoteDatasource.insertDesire(model);
  }

  @override
  Future<String> uploadImage(File file) async {
    return await remoteDatasource.uploadImage(file);
  }
}
