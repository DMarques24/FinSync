import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/entities/expense_category.dart';
import 'package:finsync/domain/repositories/desire_repository.dart';
import 'package:finsync/domain/repositories/expense_repository.dart';

/// Guarda dinheiro para um desejo.
///
/// Cruza dois lados: regista a poupança no desejo **e** cria um movimento
/// real na categoria Poupança. É o movimento que faz o saldo descer e que
/// põe o valor à vista na Home e nas análises — sem ele, o dinheiro
/// desaparecia da conta sem deixar rasto em lado nenhum.
class AddDesireSaving {
  final DesireRepository desireRepository;
  final ExpenseRepository expenseRepository;

  AddDesireSaving(this.desireRepository, this.expenseRepository);

  Future<void> call({required Desire desire, required double amount}) async {
    if (amount <= 0) {
      throw Exception('O valor a guardar tem de ser maior do que zero.');
    }

    // O movimento vem primeiro: se falhar, não fica poupança registada sem
    // a despesa correspondente. Ao contrário, o desejo dizia que tinha
    // dinheiro guardado que o saldo nunca chegou a refletir.
    await expenseRepository.insertExpense(
      Expense(
        id: 0,
        name: desire.name,
        price: amount,
        category: ExpenseCategory.poupanca,
        date: DateTime.now(),
        type: ExpenseType.despesa,
      ),
    );

    await desireRepository.addSaving(desireId: desire.id, amount: amount);
  }
}
