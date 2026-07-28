import 'package:finsync/data/datasources/expense_remote_datasource.dart'
    show kExpensesPageSize;
import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/repositories/expense_repository.dart';

class GetAllExpenses {
  final ExpenseRepository expensesRepository;

  GetAllExpenses(this.expensesRepository);

  Future<List<Expense>> call({
    int limit = kExpensesPageSize,
    int offset = 0,
  }) async {
    return await expensesRepository.getAllExpenses(
      limit: limit,
      offset: offset,
    );
  }
}
