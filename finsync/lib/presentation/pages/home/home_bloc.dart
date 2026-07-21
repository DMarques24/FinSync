import 'package:finsync/domain/usecases/get_filter_time_expenses.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finsync/domain/usecases/get_all_expenses.dart';
import 'package:finsync/domain/usecases/insert_expense.dart';
import 'package:finsync/presentation/pages/home/home_event.dart';
import 'package:finsync/presentation/pages/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetAllExpenses getAllExpenses;
  final GetFilterTimeExpenses getFilterTimeExpenses;
  final InsertExpense insertExpense;

  HomeBloc(this.getAllExpenses, this.getFilterTimeExpenses, this.insertExpense)
    : super(HomeInitialState()) {
    on<GetAllExpensesEvent>(_getAllExpenses);
    on<GetFilterTimeExpensesEvent>(_getFilterTimeExpenses);
    on<AddExpenseEvent>(_addExpense);
  }

  Future<void> _getAllExpenses(
    GetAllExpensesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadingState());

    try {
      final expenses = await getAllExpenses();
      emit(HomeLoadedState(expenses));
    } catch (e) {
      emit(HomeErrorState(e.toString()));
    }
  }

  Future<void> _getFilterTimeExpenses(
    GetFilterTimeExpensesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadingState());

    final now = DateTime.now();

    DateTime startDate;

    switch (event.filter) {
      case TimeFilter.lastDay:
        startDate = now.subtract(const Duration(days: 1));
        break;

      case TimeFilter.last7Days:
        startDate = now.subtract(const Duration(days: 7));
        break;

      case TimeFilter.last30Days:
        startDate = now.subtract(const Duration(days: 30));
        break;

      case TimeFilter.last5Months:
        startDate = DateTime(now.year, now.month - 5, now.day);
        break;
    }

    try {
      final expenses = await getFilterTimeExpenses(startDate);

      emit(HomeLoadedState(expenses));
    } catch (e) {
      emit(HomeErrorState(e.toString()));
    }
  }

  Future<void> _addExpense(
    AddExpenseEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await insertExpense(event.expense);

      final expenses = await getAllExpenses();

      emit(HomeLoadedState(expenses));
    } catch (e) {
      emit(HomeErrorState(e.toString()));
    }
  }
}
