import 'package:finsync/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();

  Future<void> insertExpense(Expense expense);
}
