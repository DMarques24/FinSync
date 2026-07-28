import 'package:finsync/data/datasources/expense_remote_datasource.dart'
    show kExpensesPageSize;
import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/repositories/expense_repository.dart';

class GetFilterTimeExpenses {
  final ExpenseRepository expenseRepository;

  GetFilterTimeExpenses(this.expenseRepository);

  Future<List<Expense>> call(
    DateTime time, {
    int limit = kExpensesPageSize,
    int offset = 0,
  }) async {
    return await expenseRepository.getFilterTimeExpenses(
      time,
      limit: limit,
      offset: offset,
    );
  }
}
