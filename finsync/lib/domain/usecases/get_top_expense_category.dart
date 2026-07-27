import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/repositories/expense_repository.dart';

class GetTopExpenseCategory {
  final ExpenseRepository expenseRepository;

  GetTopExpenseCategory(this.expenseRepository);

  Future<Expense> call() async {
    return await expenseRepository.getTopExpenseCategory();
  }
}
