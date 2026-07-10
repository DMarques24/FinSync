import 'package:finsync/domain/entities/expenses.dart' as expenses_entity;

abstract class HomeState {}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  final List<expenses_entity.Expenses> expenses;

  HomeLoadedState(this.expenses);
}

class HomeErrorState extends HomeState {
  final String message;

  HomeErrorState(this.message);
}
