import 'dart:async';
import 'dart:io';

import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/entities/expense_category.dart';

abstract class StatementEvent {}

class ParseStatementEvent extends StatementEvent {
  final File file;

  ParseStatementEvent(this.file);
}

class ToggleTransactionEvent extends StatementEvent {
  final int index;

  ToggleTransactionEvent(this.index);
}

class SelectAllTransactionsEvent extends StatementEvent {
  final bool selected;

  SelectAllTransactionsEvent(this.selected);
}

class UpdateTransactionCategoryEvent extends StatementEvent {
  final int index;
  final ExpenseCategory category;

  UpdateTransactionCategoryEvent(this.index, this.category);
}

class UpdateTransactionTypeEvent extends StatementEvent {
  final int index;
  final ExpenseType type;

  UpdateTransactionTypeEvent(this.index, this.type);
}

class ImportSelectedTransactionsEvent extends StatementEvent {
  final Completer<int>? completer;

  ImportSelectedTransactionsEvent({this.completer});
}
