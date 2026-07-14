import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/domain/repositories/desire_repository.dart';

class GetAllDesire {
  final DesireRepository desireRepository;

  GetAllDesire(this.desireRepository);

  Future<List<Desire>> call() async {
    return await desireRepository.getAllDesire();
  }
}
