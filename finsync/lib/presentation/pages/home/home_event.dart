import 'package:finsync/domain/entities/expense.dart';

abstract class HomeEvent {}

class GetAllExpensesEvent extends HomeEvent {}

class AddExpenseEvent extends HomeEvent {
  final Expense expense;

  AddExpenseEvent(this.expense);
}
