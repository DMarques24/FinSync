import 'dart:io';

import 'package:finsync/presentation/pages/create_account/create_account_page.dart';
import 'package:finsync/presentation/pages/create_account/confirm_email_page.dart';
import 'package:finsync/presentation/pages/desire/desire_detail_page.dart';
import 'package:finsync/presentation/pages/login/forgot_password_page.dart';
import 'package:finsync/presentation/pages/login/login_page.dart';
import 'package:finsync/presentation/pages/onboarding/onboarding_page.dart';
import 'package:finsync/presentation/pages/startup/startup_page.dart';
import 'package:finsync/presentation/pages/statement/import_statement_page.dart';
import 'package:go_router/go_router.dart';
import 'package:finsync/presentation/pages/main_page.dart';

/// A app abre sempre em `/`, que é o `StartupPage`.
///
/// Antes o destino inicial era decidido aqui — sessão existe, vai para a
/// Home — mas isso ignorava se a conta estava pronta a ser usada. Essa
/// decisão precisa de ler o perfil da base de dados, o que é assíncrono e
/// não cabe num `initialLocation`.
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const StartupPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/create-account',
      builder: (context, state) => const CreateAccountPage(),
    ),
    GoRoute(
      path: '/confirm-email',
      builder: (context, state) =>
          ConfirmEmailPage(email: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const MainPage()),
    GoRoute(
      path: '/desire/:id',
      builder: (context, state) => DesireDetailPage(
        desireId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
      ),
    ),
    GoRoute(
      path: '/import-statement',
      builder: (context, state) =>
          ImportStatementPage(file: state.extra as File),
    ),
  ],
);
