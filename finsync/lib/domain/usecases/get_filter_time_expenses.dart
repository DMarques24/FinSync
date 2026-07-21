import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/repositories/expense_repository.dart';

class GetFilterTimeExpenses {
  final ExpenseRepository expenseRepository;

  GetFilterTimeExpenses(this.expenseRepository);

  Future<List<Expense>> call(DateTime time) async {
    return await expenseRepository.getFilterTimeExpenses(time);
  }
}
