import 'package:finsync/domain/entities/expenses.dart';

abstract class ExpensesRepository {
  Future<List<Expenses>> getAllExpenses();

  Future<void> insertExpense(Expenses expense);
}
