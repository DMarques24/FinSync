import 'package:finsync/domain/repositories/user_repository.dart';

class CompleteOnboarding {
  final UserRepository repository;

  CompleteOnboarding(this.repository);

  Future<void> call(String userId, double balance) {
    return repository.completeOnboarding(userId, balance);
  }
}
