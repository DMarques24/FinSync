import 'package:finsync/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();
  Future<List<Expense>> getFilterTimeExpenses(DateTime time);
  Future<Expense> getTopExpenseCategory();

  Future<void> insertExpense(Expense expense);
}
