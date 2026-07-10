import 'package:finsync/domain/usecases/get_all_expenses.dart';
import 'package:finsync/presentation/pages/home/home_event.dart';
import 'package:finsync/presentation/pages/home/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetAllExpenses getAllExpenses;

  HomeBloc(this.getAllExpenses) : super(HomeInitialState()) {
    on<GetAllExpensesEvent>(_getAllExpenses);
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
}
