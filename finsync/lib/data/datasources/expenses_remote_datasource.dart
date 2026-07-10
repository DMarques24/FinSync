import 'package:finsync/data/models/expenses_model.dart';

abstract class ExpensesRemoteDatasource {
  Future<List<ExpensesModel>> getAllExpenses();
}
