import 'package:finsync/data/datasources/expense_remote_datasource.dart'
    show kExpensesPageSize;
import 'package:finsync/domain/usecases/apply_due_calendar_events.dart';
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
  final ApplyDueCalendarEvents applyDueCalendarEvents;

  HomeBloc(
    this.getAllExpenses,
    this.getFilterTimeExpenses,
    this.insertExpense,
    this.applyDueCalendarEvents,
  ) : super(HomeInitialState()) {
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
      // Os eventos do calendário cujo dia já chegou entram aqui como
      // movimentos. É por isto que abrir a app é suficiente para o saldo
      // ficar em dia — não há nada agendado do lado do servidor.
      await _applyDueEvents();

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

  /// Uma falha a lançar eventos não pode impedir a Home de abrir: os
  /// movimentos que já existem continuam a ser mostrados, e na próxima
  /// tentativa os eventos em atraso são apanhados na mesma.
  Future<void> _applyDueEvents() async {
    try {
      await applyDueCalendarEvents();
    } catch (_) {
      // Silenciado de propósito — ver comentário acima.
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
