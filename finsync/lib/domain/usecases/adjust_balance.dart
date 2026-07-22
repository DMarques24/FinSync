import 'package:finsync/domain/repositories/user_repository.dart';

class AdjustBalance {
  final UserRepository repository;

  AdjustBalance(this.repository);

  Future<void> call(double delta) {
    return repository.adjustBalance(delta);
  }
}
