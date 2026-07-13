import 'package:finsync/domain/entities/desire.dart';

abstract class DesireRepository {
  Future<List<Desire>> getAllDesire();
}
