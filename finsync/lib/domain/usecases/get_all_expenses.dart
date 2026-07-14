import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/repositories/expense_repository.dart';

class GetAllExpenses {
  final ExpenseRepository expensesRepository;

  GetAllExpenses(this.expensesRepository);

  Future<List<Expense>> call() async {
    return await expensesRepository.getAllExpenses();
  }
}
