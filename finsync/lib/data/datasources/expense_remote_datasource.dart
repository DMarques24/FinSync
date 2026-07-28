import 'package:finsync/data/models/expense_model.dart';

const int kExpensesPageSize = 30;


const int kAnalyticsExpensesLimit = 1000;

abstract class ExpenseRemoteDatasource {
  Future<List<ExpenseModel>> getAllExpenses({
    int limit = kExpensesPageSize,
    int offset = 0,
  });

  Future<List<ExpenseModel>> getFilterTimeExpenses(
    DateTime time, {
    int limit = kExpensesPageSize,
    int offset = 0,
  });

  Future<ExpenseModel> getTopExpenseCategory();

  Future<void> insertExpense(ExpenseModel expense);

  Future<void> insertExpenses(List<ExpenseModel> expenses);
}
