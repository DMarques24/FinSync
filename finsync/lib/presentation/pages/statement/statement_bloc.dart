import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/entities/expense_category.dart';
import 'package:finsync/domain/usecases/import_parsed_transactions.dart';
import 'package:finsync/domain/usecases/parse_bank_statement.dart';
import 'package:finsync/presentation/pages/statement/statement_event.dart';
import 'package:finsync/presentation/pages/statement/statement_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatementBloc extends Bloc<StatementEvent, StatementState> {
  final ParseBankStatement parseBankStatement;
  final ImportParsedTransactions importParsedTransactions;

  StatementBloc(this.parseBankStatement, this.importParsedTransactions)
    : super(StatementInitialState()) {
    on<ParseStatementEvent>(_onParse);
    on<ToggleTransactionEvent>(_onToggle);
    on<SelectAllTransactionsEvent>(_onSelectAll);
    on<UpdateTransactionCategoryEvent>(_onUpdateCategory);
    on<UpdateTransactionTypeEvent>(_onUpdateType);
    on<ImportSelectedTransactionsEvent>(_onImport);
  }

  Future<void> _onParse(
    ParseStatementEvent event,
    Emitter<StatementState> emit,
  ) async {
    emit(StatementParsingState());

    try {
      final transactions = await parseBankStatement(event.file);

      final selected = <int>{
        for (var i = 0; i < transactions.length; i++)
          if (transactions[i].isReliable && transactions[i].category != null)
            i,
      };

      emit(
        StatementReviewState(
          transactions: transactions,
          selectedIndexes: selected,
        ),
      );
    } catch (e) {
      emit(StatementErrorState(_message(e)));
    }
  }

  void _onToggle(ToggleTransactionEvent event, Emitter<StatementState> emit) {
    final current = state;
    if (current is! StatementReviewState) return;

    final selected = Set<int>.from(current.selectedIndexes);
    if (!selected.remove(event.index)) selected.add(event.index);

    emit(current.copyWith(selectedIndexes: selected));
  }

  void _onSelectAll(
    SelectAllTransactionsEvent event,
    Emitter<StatementState> emit,
  ) {
    final current = state;
    if (current is! StatementReviewState) return;

    emit(
      current.copyWith(
        selectedIndexes: event.selected
            ? {for (var i = 0; i < current.transactions.length; i++) i}
            : <int>{},
      ),
    );
  }

  void _onUpdateCategory(
    UpdateTransactionCategoryEvent event,
    Emitter<StatementState> emit,
  ) {
    final current = state;
    if (current is! StatementReviewState) return;

    final updated = [...current.transactions];
    updated[event.index] = updated[event.index].copyWith(
      category: event.category,
    );

    final selected = Set<int>.from(current.selectedIndexes)..add(event.index);

    emit(current.copyWith(transactions: updated, selectedIndexes: selected));
  }

  void _onUpdateType(
    UpdateTransactionTypeEvent event,
    Emitter<StatementState> emit,
  ) {
    final current = state;
    if (current is! StatementReviewState) return;

    final updated = [...current.transactions];
    final transaction = updated[event.index];

    if (event.type == ExpenseType.receita) {
      // Passou a receita: a categoria é `rendimento` e deixa de haver
      // escolha a fazer.
      updated[event.index] = transaction.copyWith(
        type: event.type,
        category: ExpenseCategory.income,
      );
    } else {
      // Voltou a despesa: `rendimento` não serve, e obrigar a escolher é
      // melhor do que arriscar uma categoria errada.
      updated[event.index] = transaction.copyWith(
        type: event.type,
        clearCategory: transaction.category?.isIncome ?? false,
      );
    }

    emit(current.copyWith(transactions: updated));
  }

  Future<void> _onImport(
    ImportSelectedTransactionsEvent event,
    Emitter<StatementState> emit,
  ) async {
    final current = state;
    if (current is! StatementReviewState) return;

    emit(current.copyWith(isImporting: true));

    try {
      final imported = await importParsedTransactions(
        current.selectedTransactions,
      );
      event.completer?.complete(imported);
    } catch (e) {
      emit(current.copyWith(isImporting: false));
      event.completer?.completeError(_message(e));
    }
  }

  String _message(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
