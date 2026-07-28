import 'package:finsync/domain/entities/parsed_transaction.dart';
import 'package:finsync/domain/repositories/expense_repository.dart';


class ImportParsedTransactions {
  final ExpenseRepository repository;

  ImportParsedTransactions(this.repository);

  Future<int> call(List<ParsedTransaction> transactions) async {
    if (transactions.isEmpty) return 0;

    await repository.insertExpenses(
      transactions.map((transaction) => transaction.toExpense()).toList(),
    );

    return transactions.length;
  }
}
