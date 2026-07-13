import 'package:finsync/domain/entities/expenses.dart';

abstract class HomeEvent {}

class GetAllExpensesEvent extends HomeEvent {}

class AddExpenseEvent extends HomeEvent {
  final Expenses expense;

  AddExpenseEvent(this.expense);
}
