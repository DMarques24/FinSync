import 'package:finsync/domain/entities/expenses.dart';
import 'package:finsync/domain/repositories/expenses_repository.dart';

class GetAllExpenses {
  final ExpensesRepository expensesRepository;

  GetAllExpenses(this.expensesRepository);

  Future<List<Expenses>> call() async {
    return await expensesRepository.getAllExpenses();
  }
}
