import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/domain/repositories/desire_repository.dart';

class InsertDesire {
  final DesireRepository repository;

  InsertDesire(this.repository);

  Future<void> call(Desire desire) {
    return repository.insertDesire(desire);
  }
}
