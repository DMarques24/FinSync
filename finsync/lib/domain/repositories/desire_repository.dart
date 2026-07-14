import 'package:finsync/domain/entities/desire.dart';

abstract class DesireRepository {
  Future<List<Desire>> getAllDesires();

  Future<void> insertDesire(Desire desire);
}
