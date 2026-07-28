import 'package:finsync/domain/entities/expense.dart';

abstract class HomeState {}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  final List<Expense> expenses;

  /// Falso quando a última página veio incompleta — sinal de que já não há
  /// mais nada para ir buscar e a lista pode parar de pedir.
  final bool hasMore;

  /// Verdadeiro enquanto a página seguinte está a ser carregada, para a
  /// lista mostrar o indicador no fundo sem substituir o que já lá está.
  final bool isLoadingMore;

  /// Filtro de período ativo, guardado para que "carregar mais" continue
  /// a pedir o mesmo recorte em vez de voltar a todas as despesas.
  final DateTime? filterStartDate;

  HomeLoadedState(
    this.expenses, {
    this.hasMore = false,
    this.isLoadingMore = false,
    this.filterStartDate,
  });

  HomeLoadedState copyWith({
    List<Expense>? expenses,
    bool? hasMore,
    bool? isLoadingMore,
    DateTime? filterStartDate,
    bool clearFilter = false,
  }) {
    return HomeLoadedState(
      expenses ?? this.expenses,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filterStartDate: clearFilter
          ? null
          : (filterStartDate ?? this.filterStartDate),
    );
  }
}

class HomeErrorState extends HomeState {
  final String message;

  HomeErrorState(this.message);
}
