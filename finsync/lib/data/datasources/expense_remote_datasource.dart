import 'package:finsync/data/models/expense_model.dart';

abstract class ExpenseRemoteDatasource {
  Future<List<ExpenseModel>> getAllExpenses();

  Future<void> insertExpense(ExpenseModel expense);
}
