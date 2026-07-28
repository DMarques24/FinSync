import 'package:finsync/domain/entities/expense.dart';

enum TimeFilter { lastDay, last7Days, last30Days, last5Months }

abstract class HomeEvent {}

class GetAllExpensesEvent extends HomeEvent {}

class GetFilterTimeExpensesEvent extends HomeEvent {
  final TimeFilter filter;

  GetFilterTimeExpensesEvent(this.filter);
}

class LoadMoreExpensesEvent extends HomeEvent {}

class AddExpenseEvent extends HomeEvent {
  final Expense expense;

  AddExpenseEvent(this.expense);
}
