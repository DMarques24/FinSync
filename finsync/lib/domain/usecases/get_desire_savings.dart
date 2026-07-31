import 'package:finsync/domain/entities/desire_saving.dart';
import 'package:finsync/domain/repositories/desire_repository.dart';

class GetDesireSavings {
  final DesireRepository repository;

  GetDesireSavings(this.repository);

  Future<List<DesireSaving>> call(int desireId) {
    return repository.getSavings(desireId);
  }
}
