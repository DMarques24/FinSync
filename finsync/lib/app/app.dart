import 'package:finsync/presentation/pages/analytics/analytics_bloc.dart';
import 'package:finsync/presentation/pages/createAcount/create_acount_bloc.dart';
import 'package:finsync/presentation/pages/login/login_bloc.dart';
import 'package:finsync/presentation/pages/onboarding/onboarding_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:finsync/app/app_router.dart';
import 'package:finsync/core/di/injection.dart';
import 'package:finsync/core/theme/app_theme.dart';
import 'package:finsync/core/theme/theme_bloc.dart';
import 'package:finsync/core/theme/theme_event.dart';
import 'package:finsync/core/theme/theme_state.dart';
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
        BlocProvider<CreateAcountBloc>(create: (_) => sl<CreateAcountBloc>()),
        BlocProvider<OnboardingBloc>(create: (_) => sl<OnboardingBloc>()),
        BlocProvider<ProfileBloc>(
          create: (_) => sl<ProfileBloc>()..add(LoadProfileEvent()),
        ),
        BlocProvider(create: (_) => sl<AnalyticsBloc>()),
        BlocProvider<ThemeBloc>(
          create: (_) => sl<ThemeBloc>()..add(LoadThemeEvent()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            key: ValueKey(themeState.mode),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.mode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
