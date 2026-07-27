import 'package:finsync/data/datasources/calendar_events_remote_datasource.dart';
import 'package:finsync/data/datasources/calendar_events_remote_datasource_impl.dart';
import 'package:finsync/data/repositories/calendar_events_repository_impl.dart';
import 'package:finsync/domain/repositories/calendar_event_repository.dart';
import 'package:finsync/domain/usecases/adjust_balance.dart';
import 'package:finsync/domain/usecases/complete_onboarding.dart';
import 'package:finsync/domain/usecases/delete_calendar_event.dart';
import 'package:finsync/domain/usecases/get_all_calendar_events.dart';
import 'package:finsync/domain/usecases/get_filter_time_expenses.dart';
import 'package:finsync/domain/usecases/get_top_expense_category.dart';
import 'package:finsync/domain/usecases/insert_calendar_event.dart';
import 'package:finsync/domain/usecases/insert_user.dart';
import 'package:finsync/presentation/pages/analytics/analytics_bloc.dart';
import 'package:finsync/presentation/pages/createAcount/create_acount_bloc.dart';
import 'package:finsync/presentation/pages/login/login_bloc.dart';
import 'package:finsync/presentation/pages/onboarding/onboarding_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_bloc.dart';
import 'package:finsync/core/theme/theme_bloc.dart';
import 'package:finsync/core/currency/currency_bloc.dart';
import 'package:finsync/core/locale/locale_bloc.dart';
import 'package:finsync/core/notifications/notification_prefs_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:finsync/data/datasources/auth_user_remote_datasource.dart';
import 'package:finsync/data/datasources/auth_user_remote_datasource_impl.dart';
import 'package:finsync/data/datasources/desire_remote_datasource.dart';
import 'package:finsync/data/datasources/desire_remote_datasource_impl.dart';
import 'package:finsync/data/datasources/expense_remote_datasource.dart';
import 'package:finsync/data/datasources/expense_remote_datasource_impl.dart';
import 'package:finsync/data/datasources/pdf_remote_datasource.dart';
import 'package:finsync/data/datasources/pdf_remote_datasource_impl.dart';
import 'package:finsync/data/datasources/user_remote_datasource.dart';
import 'package:finsync/data/datasources/user_remote_datasource_impl.dart';

import 'package:finsync/data/repositories/auth_user_repository_impl.dart';
import 'package:finsync/data/repositories/desire_repository_impl.dart';
import 'package:finsync/data/repositories/expense_repository_impl.dart';
import 'package:finsync/data/repositories/pdf_repository_impl.dart';
import 'package:finsync/data/repositories/user_repository_impl.dart';

import 'package:finsync/domain/repositories/auth_user_repository.dart';
import 'package:finsync/domain/repositories/desire_repository.dart';
import 'package:finsync/domain/repositories/expense_repository.dart';
import 'package:finsync/domain/repositories/pdf_repository.dart';
import 'package:finsync/domain/repositories/user_repository.dart';

import 'package:finsync/domain/usecases/change_password.dart';
import 'package:finsync/domain/usecases/create_analytics_pdf.dart';
import 'package:finsync/domain/usecases/get_all_desires.dart';
import 'package:finsync/domain/usecases/get_all_expenses.dart';
import 'package:finsync/domain/usecases/get_user.dart';
import 'package:finsync/domain/usecases/insert_desire.dart';
import 'package:finsync/domain/usecases/update_user_profile.dart';
import 'package:finsync/domain/usecases/upload_avatar_image.dart';
import 'package:finsync/domain/usecases/upload_desire_image.dart';
import 'package:finsync/domain/usecases/insert_expense.dart';
import 'package:finsync/domain/usecases/sign_in_user.dart';
import 'package:finsync/domain/usecases/sign_out_user.dart';
import 'package:finsync/domain/usecases/sign_up_user.dart';

import 'package:finsync/presentation/pages/desire/desire_bloc.dart';
import 'package:finsync/presentation/pages/home/home_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ? DATASOURCES
  sl.registerLazySingleton<AuthUserRemoteDatasource>(
    () => AuthUserRemoteDatasourceImpl(),
  );

  sl.registerLazySingleton<ExpenseRemoteDatasource>(
    () => ExpenseRemoteDatasourceImpl(),
  );

  sl.registerLazySingleton<DesireRemoteDatasource>(
    () => DesireRemoteDatasourceImpl(),
  );

  sl.registerLazySingleton<PdfRemoteDatasource>(
    () => PdfRemoteDatasourceImpl(),
  );

  sl.registerLazySingleton<UserRemoteDatasource>(
    () => UserRemoteDatasourceImpl(),
  );

  sl.registerLazySingleton<CalendarEventsRemoteDatasource>(
    () => CalendarEventsRemoteDatasourceImpl(),
  );

  // REPOSITORIES
  sl.registerLazySingleton<AuthUserRepository>(
    () => AuthUserRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<DesireRepository>(() => DesireRepositoryImpl(sl()));

  sl.registerLazySingleton<PdfRepository>(() => PdfRepositoryImpl(sl()));

  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  sl.registerLazySingleton<CalendarEventRepository>(
    () => CalendarEventsRepositoryImpl(sl()),
  );

  // USE CASES
  sl.registerLazySingleton<SignInUser>(() => SignInUser(sl()));

  sl.registerLazySingleton<SignUpUser>(() => SignUpUser(sl()));

  sl.registerLazySingleton<SignOutUser>(() => SignOutUser(sl()));

  sl.registerLazySingleton<InsertUser>(() => InsertUser(sl()));

  sl.registerLazySingleton<GetAllExpenses>(() => GetAllExpenses(sl()));

  sl.registerLazySingleton<GetFilterTimeExpenses>(
    () => GetFilterTimeExpenses(sl()),
  );

  sl.registerLazySingleton<InsertExpense>(() => InsertExpense(sl()));

  sl.registerLazySingleton<CreateAnalyticsPdf>(() => CreateAnalyticsPdf(sl()));

  sl.registerLazySingleton<GetAllDesires>(() => GetAllDesires(sl()));

  sl.registerLazySingleton<InsertDesire>(() => InsertDesire(sl()));

  sl.registerLazySingleton<UploadDesireImage>(() => UploadDesireImage(sl()));

  sl.registerLazySingleton<GetUser>(() => GetUser(sl()));

  sl.registerLazySingleton<UpdateUserProfile>(() => UpdateUserProfile(sl()));

  sl.registerLazySingleton<UploadAvatarImage>(() => UploadAvatarImage(sl()));

  sl.registerLazySingleton<ChangePassword>(() => ChangePassword(sl()));

  sl.registerLazySingleton<CompleteOnboarding>(() => CompleteOnboarding(sl()));

  sl.registerLazySingleton<AdjustBalance>(() => AdjustBalance(sl()));

  sl.registerLazySingleton<GetAllCalendarEvents>(
    () => GetAllCalendarEvents(sl()),
  );

  sl.registerLazySingleton<InsertCalendarEvent>(
    () => InsertCalendarEvent(sl()),
  );

  sl.registerLazySingleton<DeleteCalendarEvent>(
    () => DeleteCalendarEvent(sl()),
  );

  sl.registerLazySingleton<GetTopExpenseCategory>(
    () => GetTopExpenseCategory(sl()),
  );

  // BLOCS
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(
      sl<GetAllExpenses>(),
      sl<GetFilterTimeExpenses>(),
      sl<InsertExpense>(),
    ),
  );

  sl.registerFactory<DesireBloc>(
    () => DesireBloc(
      sl<GetAllDesires>(),
      sl<InsertDesire>(),
      sl<AdjustBalance>(),
      sl<UploadDesireImage>(),
    ),
  );

  sl.registerFactory<LoginBloc>(
    () => LoginBloc(sl<SignInUser>(), sl<GetUser>()),
  );

  sl.registerFactory<CreateAcountBloc>(
    () => CreateAcountBloc(sl<SignUpUser>(), sl<InsertUser>()),
  );

  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      sl<GetUser>(),
      sl<UpdateUserProfile>(),
      sl<UploadAvatarImage>(),
    ),
  );

  sl.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(sl<CompleteOnboarding>()),
  );

  sl.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(
      sl<GetAllExpenses>(),
      sl<InsertCalendarEvent>(),
      sl<GetAllCalendarEvents>(),
      sl<AdjustBalance>(),
      sl<DeleteCalendarEvent>(),
      sl<CreateAnalyticsPdf>(),
    ),
  );

  sl.registerFactory<ThemeBloc>(() => ThemeBloc());
  sl.registerFactory<CurrencyBloc>(() => CurrencyBloc());
  sl.registerFactory<LocaleBloc>(() => LocaleBloc());
  sl.registerFactory<NotificationPrefsBloc>(() => NotificationPrefsBloc());
}
