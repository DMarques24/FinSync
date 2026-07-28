import 'package:finsync/data/datasources/expense_remote_datasource.dart';
import 'package:finsync/data/models/expense_model.dart';
import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDatasource remoteDatasource;

  ExpenseRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Expense>> getAllExpenses({
    int limit = kExpensesPageSize,
    int offset = 0,
  }) async {
    final models = await remoteDatasource.getAllExpenses(
      limit: limit,
      offset: offset,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Expense>> getFilterTimeExpenses(
    DateTime time, {
    int limit = kExpensesPageSize,
    int offset = 0,
  }) async {
    final models = await remoteDatasource.getFilterTimeExpenses(
      time,
      limit: limit,
      offset: offset,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Expense> getTopExpenseCategory() async {
    final model = await remoteDatasource.getTopExpenseCategory();
    return model.toEntity();
  }

  @override
  Future<void> insertExpense(Expense expense) async {
    await remoteDatasource.insertExpense(_toModel(expense));
  }

  @override
  Future<void> insertExpenses(List<Expense> expenses) async {
    await remoteDatasource.insertExpenses(expenses.map(_toModel).toList());
  }

  ExpenseModel _toModel(Expense expense) => ExpenseModel(
    id: expense.id,
    name: expense.name,
    price: expense.price,
    category: expense.category,
    date: expense.date,
    type: expense.type,
  );
}
