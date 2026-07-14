import 'package:finsync/domain/entities/expense.dart' as expense_entity;

abstract class HomeState {}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  final List<expense_entity.Expense> expenses;

  HomeLoadedState(this.expenses);
}

class HomeErrorState extends HomeState {
  final String message;

  HomeErrorState(this.message);
}
