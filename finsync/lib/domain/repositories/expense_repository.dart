import 'package:finsync/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getAllExpenses({int limit, int offset});

  Future<List<Expense>> getFilterTimeExpenses(
    DateTime time, {
    int limit,
    int offset,
  });

  Future<Expense> getTopExpenseCategory();

  Future<void> insertExpense(Expense expense);

  Future<void> insertExpenses(List<Expense> expenses);
}
