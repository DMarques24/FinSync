import 'dart:io';

import 'package:finsync/data/models/desire_model.dart';

abstract class DesireRemoteDatasource {
  Future<List<DesireModel>> getAllDesires();

  Future<void> insertDesire(DesireModel desire);

  Future<String> uploadImage(File file);
}
