import 'package:finsync/data/datasources/expense_remote_datasource.dart'
    show kExpensesPageSize;
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
    on<LoadMoreExpensesEvent>(_loadMoreExpenses);
    on<AddExpenseEvent>(_addExpense);
  }

  Future<void> _getAllExpenses(
    GetAllExpensesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadingState());

    try {
      final expenses = await getAllExpenses();
      emit(
        HomeLoadedState(
          expenses,
          hasMore: expenses.length == kExpensesPageSize,
        ),
      );
    } catch (e) {
      emit(HomeErrorState(e.toString()));
    }
  }

  Future<void> _getFilterTimeExpenses(
    GetFilterTimeExpensesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadingState());

    final startDate = _startDateFor(event.filter);

    try {
      final expenses = await getFilterTimeExpenses(startDate);

      emit(
        HomeLoadedState(
          expenses,
          hasMore: expenses.length == kExpensesPageSize,
          filterStartDate: startDate,
        ),
      );
    } catch (e) {
      emit(HomeErrorState(e.toString()));
    }
  }

  Future<void> _loadMoreExpenses(
    LoadMoreExpensesEvent event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is! HomeLoadedState) return;

    if (current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));

    try {
      final filter = current.filterStartDate;
      final nextPage = filter == null
          ? await getAllExpenses(offset: current.expenses.length)
          : await getFilterTimeExpenses(
              filter,
              offset: current.expenses.length,
            );

      emit(
        current.copyWith(
          expenses: [...current.expenses, ...nextPage],
          hasMore: nextPage.length == kExpensesPageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _addExpense(
    AddExpenseEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await insertExpense(event.expense);

      final expenses = await getAllExpenses();
      emit(
        HomeLoadedState(
          expenses,
          hasMore: expenses.length == kExpensesPageSize,
        ),
      );
    } catch (e) {
      emit(HomeErrorState(e.toString()));
    }
  }

  DateTime _startDateFor(TimeFilter filter) {
    final now = DateTime.now();

    switch (filter) {
      case TimeFilter.lastDay:
        return now.subtract(const Duration(days: 1));
      case TimeFilter.last7Days:
        return now.subtract(const Duration(days: 7));
      case TimeFilter.last30Days:
        return now.subtract(const Duration(days: 30));
      case TimeFilter.last5Months:
        return DateTime(now.year, now.month - 5, now.day);
    }
  }
}
