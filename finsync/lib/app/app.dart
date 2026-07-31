import 'package:finsync/presentation/pages/analytics/analytics_bloc.dart';
import 'package:finsync/presentation/pages/create_account/create_account_bloc.dart';
import 'package:finsync/presentation/pages/login/login_bloc.dart';
import 'package:finsync/presentation/pages/onboarding/onboarding_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:finsync/app/app_router.dart';
import 'package:finsync/core/di/injection.dart';
import 'package:finsync/core/theme/app_theme.dart';
import 'package:finsync/core/theme/theme_bloc.dart';
import 'package:finsync/core/theme/theme_event.dart';
import 'package:finsync/core/theme/theme_state.dart';
import 'package:finsync/core/currency/currency_bloc.dart';
import 'package:finsync/core/currency/currency_event.dart';
import 'package:finsync/core/currency/currency_state.dart';
import 'package:finsync/core/locale/locale_bloc.dart';
import 'package:finsync/core/locale/locale_event.dart';
import 'package:finsync/core/locale/locale_state.dart';
import 'package:finsync/core/notifications/notification_prefs_bloc.dart';
import 'package:finsync/core/notifications/notification_prefs_event.dart';
import 'package:finsync/presentation/pages/home/home_bloc.dart';
import 'package:finsync/presentation/pages/desire/desire_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(create: (_) => sl<HomeBloc>()),
        BlocProvider<DesireBloc>(create: (_) => sl<DesireBloc>()),
        BlocProvider<LoginBloc>(create: (_) => sl<LoginBloc>()),
        BlocProvider<CreateAccountBloc>(create: (_) => sl<CreateAccountBloc>()),
        BlocProvider<OnboardingBloc>(create: (_) => sl<OnboardingBloc>()),
        // Sem evento de carregamento aqui: quem decide se há perfil para
        // ler é o `StartupPage`, que corre depois de a sessão estar
        // resolvida. Pedi-lo no arranque deixava o bloco em erro quando
        // ainda não havia sessão, e esse erro sobrevivia ao login inteiro.
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
        BlocProvider(create: (_) => sl<AnalyticsBloc>()),
        BlocProvider<ThemeBloc>(
          create: (_) => sl<ThemeBloc>()..add(LoadThemeEvent()),
        ),
        BlocProvider<CurrencyBloc>(
          create: (_) => sl<CurrencyBloc>()..add(LoadCurrencyEvent()),
        ),
        BlocProvider<LocaleBloc>(
          create: (_) => sl<LocaleBloc>()..add(LoadLocaleEvent()),
        ),
        BlocProvider<NotificationPrefsBloc>(
          create: (_) =>
              sl<NotificationPrefsBloc>()..add(LoadNotificationPrefsEvent()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<CurrencyBloc, CurrencyState>(
            builder: (context, currencyState) {
              return BlocBuilder<LocaleBloc, LocaleState>(
                builder: (context, localeState) {
                  return MaterialApp.router(
                    key: ValueKey(
                      '${themeState.mode}_${currencyState.type.code}_${localeState.type.code}',
                    ),
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeState.mode,
                    routerConfig: router,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
