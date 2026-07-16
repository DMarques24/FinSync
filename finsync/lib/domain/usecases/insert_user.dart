import 'package:finsync/domain/entities/user.dart';
import 'package:finsync/domain/repositories/user_repository.dart';

class InsertUser {
  final UserRepository repository;

  InsertUser(this.repository);

  Future<void> call(User user, String userId) {
    return repository.insertUser(user, userId);
  }
}
