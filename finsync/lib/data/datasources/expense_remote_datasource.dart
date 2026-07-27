import 'package:finsync/data/models/expense_model.dart';

abstract class ExpenseRemoteDatasource {
  Future<List<ExpenseModel>> getAllExpenses();
  Future<List<ExpenseModel>> getFilterTimeExpenses(DateTime time);
  Future<ExpenseModel> getTopExpenseCategory();
  Future<void> insertExpense(ExpenseModel expense);
}
