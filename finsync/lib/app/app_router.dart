import 'dart:io';

import 'package:finsync/presentation/pages/create_account/create_account_page.dart';
import 'package:finsync/presentation/pages/login/login_page.dart';
import 'package:finsync/presentation/pages/onboarding/onboarding_page.dart';
import 'package:finsync/presentation/pages/statement/import_statement_page.dart';
import 'package:go_router/go_router.dart';
import 'package:finsync/presentation/pages/main_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final session = Supabase.instance.client.auth.currentSession;

final router = GoRouter(
  initialLocation: session != null ? '/' : '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/create-account',
      builder: (context, state) => const CreateAccountPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(path: '/', builder: (context, state) => const MainPage()),
    GoRoute(
      path: '/import-statement',
      builder: (context, state) =>
          ImportStatementPage(file: state.extra as File),
    ),
  ],
);
