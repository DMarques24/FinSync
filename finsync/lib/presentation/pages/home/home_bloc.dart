import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finsync/domain/usecases/get_all_expenses.dart';
import 'package:finsync/domain/usecases/insert_expense.dart';
import 'package:finsync/presentation/pages/home/home_event.dart';
import 'package:finsync/presentation/pages/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetAllExpenses getAllExpenses;
  final InsertExpense insertExpense;

  HomeBloc(this.getAllExpenses, this.insertExpense)
    : super(HomeInitialState()) {
    on<GetAllExpensesEvent>(_getAllExpenses);
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

  Future<void> _addExpense(
    AddExpenseEvent event,
    Emitter<HomeState> emit,
  ) async {
    print("Evento recebido!");

    try {
      await insertExpense(event.expense);

      print("Despesa inserida!");

      final expenses = await getAllExpenses();

      emit(HomeLoadedState(expenses));
    } catch (e, s) {
      print(e);
      print(s);
      emit(HomeErrorState(e.toString()));
    }
  }
}
