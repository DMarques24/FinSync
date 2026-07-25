import 'dart:io';

import 'package:finsync/domain/entities/desire.dart';

abstract class DesireRepository {
  Future<List<Desire>> getAllDesires();

  Future<void> insertDesire(Desire desire);

  Future<String> uploadImage(File file);
}
