import 'package:finsync/data/datasources/expense_remote_datasource.dart';
import 'package:finsync/data/models/expense_model.dart';
import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDatasource remoteDatasource;

  ExpenseRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Expense>> getAllExpenses() async {
    final models = await remoteDatasource.getAllExpenses();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Expense>> getFilterTimeExpenses(DateTime time) async {
    final models = await remoteDatasource.getFilterTimeExpenses(time);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> insertExpense(Expense expense) async {
    final model = ExpenseModel(
      id: expense.id,
      name: expense.name,
      price: expense.price,
      category: expense.category,
      date: expense.date,
    );
    await remoteDatasource.insertExpense(model);
  }
}
