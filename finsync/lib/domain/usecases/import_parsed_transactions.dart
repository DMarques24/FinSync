import 'package:finsync/domain/entities/parsed_transaction.dart';
import 'package:finsync/domain/repositories/expense_repository.dart';

class ImportParsedTransactions {
  final ExpenseRepository repository;

  ImportParsedTransactions(this.repository);

  Future<int> call(List<ParsedTransaction> transactions) async {
    var imported = 0;
    for (final transaction in transactions) {
      await repository.insertExpense(transaction.toExpense());
      imported++;
    }
    return imported;
  }
}
