import 'package:finsync/domain/entities/parsed_transaction.dart';

abstract class StatementState {}

class StatementInitialState extends StatementState {}

class StatementParsingState extends StatementState {}

class StatementReviewState extends StatementState {
  final List<ParsedTransaction> transactions;
  final Set<int> selectedIndexes;
  final bool isImporting;

  StatementReviewState({
    required this.transactions,
    required this.selectedIndexes,
    this.isImporting = false,
  });

  int get selectedCount => selectedIndexes.length;

  bool get allSelected =>
      transactions.isNotEmpty && selectedIndexes.length == transactions.length;

  List<ParsedTransaction> get selectedTransactions => [
    for (var i = 0; i < transactions.length; i++)
      if (selectedIndexes.contains(i)) transactions[i],
  ];

  StatementReviewState copyWith({
    List<ParsedTransaction>? transactions,
    Set<int>? selectedIndexes,
    bool? isImporting,
  }) {
    return StatementReviewState(
      transactions: transactions ?? this.transactions,
      selectedIndexes: selectedIndexes ?? this.selectedIndexes,
      isImporting: isImporting ?? this.isImporting,
    );
  }
}

class StatementErrorState extends StatementState {
  final String message;

  StatementErrorState(this.message);
}
