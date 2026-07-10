import 'package:finsync/data/datasources/expenses_remote_datasource.dart';
import 'package:finsync/domain/entities/expenses.dart';
import 'package:finsync/domain/repositories/expenses_repository.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesRemoteDatasource remoteDatasource;

  ExpensesRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Expenses>> getAllExpenses() async {
    final models = await remoteDatasource.getAllExpenses();
    return models.map((model) => model.toEntity()).toList();
  }
}
