import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/repositories/expense_repository.dart';

class InsertExpense {
  final ExpenseRepository repository;

  InsertExpense(this.repository);

  Future<void> call(Expense expense) {
    return repository.insertExpense(expense);
  }
}
