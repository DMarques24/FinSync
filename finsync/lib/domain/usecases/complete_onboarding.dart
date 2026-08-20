import 'package:finsync/domain/repositories/user_repository.dart';

class CompleteOnboarding {
  final UserRepository repository;

  CompleteOnboarding(this.repository);

  Future<void> call(
    String userId, {
    required double balance,
    required double monthlyIncome,
  }) {
    return repository.completeOnboarding(
      userId,
      balance: balance,
      monthlyIncome: monthlyIncome,
    );
  }
}
