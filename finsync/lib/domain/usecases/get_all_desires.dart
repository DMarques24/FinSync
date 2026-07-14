import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/domain/repositories/desire_repository.dart';

class GetAllDesires {
  final DesireRepository desireRepository;

  GetAllDesires(this.desireRepository);

  Future<List<Desire>> call() async {
    return await desireRepository.getAllDesires();
  }
}
