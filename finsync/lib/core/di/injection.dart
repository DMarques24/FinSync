import 'package:finsync/data/datasources/desire_remote_datasource.dart';
import 'package:finsync/data/datasources/desire_remote_datasource_impl.dart';
import 'package:finsync/data/datasources/expenses_remote_datasource.dart';
import 'package:finsync/data/datasources/expenses_remote_datasource_impl.dart';
import 'package:finsync/data/repositories/desire_repository_impl.dart';
import 'package:finsync/data/repositories/expenses_repository_impl.dart';
import 'package:finsync/domain/repositories/desire_repository.dart';
import 'package:finsync/domain/repositories/expenses_repository.dart';
import 'package:finsync/domain/usecases/get_all_desire.dart';
import 'package:finsync/domain/usecases/get_all_expenses.dart';
import 'package:finsync/presentation/pages/desire/desire_bloc.dart';
import 'package:finsync/presentation/pages/home/home_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  //CORE
  //API
  //DATASOURCE
  sl.registerLazySingleton<ExpensesRemoteDatasource>(
    () => ExpensesRemoteDatasourceImpl(),
  );

  sl.registerLazySingleton<DesireRemoteDatasource>(
    () => DesireRemoteDatasourceImpl(),
  );

  //REPOSITORY
  sl.registerLazySingleton<ExpensesRepository>(
    () => ExpensesRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<DesireRepository>(() => DesireRepositoryImpl(sl()));
  //USECASE
  sl.registerLazySingleton(() => GetAllExpenses(sl()));

  sl.registerLazySingleton(() => GetAllDesire(sl()));
  //BLOC
  sl.registerFactory(() => HomeBloc(sl()));

  sl.registerFactory(() => DesireBloc(sl()));
}
