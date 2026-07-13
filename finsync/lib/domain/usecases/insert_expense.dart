import 'package:finsync/domain/entities/expenses.dart';
import 'package:finsync/domain/repositories/expenses_repository.dart';

class InsertExpense {
  final ExpensesRepository repository;

  InsertExpense(this.repository);

  Future<void> call(Expenses expense) {
    return repository.insertExpense(expense);
  }
}
