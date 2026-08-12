import 'dart:async';

import 'package:finsync/core/di/injection.dart';
import 'package:finsync/core/errors/app_error_translator.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/usecases/get_user.dart';
import 'package:finsync/domain/usecases/reschedule_notifications.dart';
import 'package:finsync/domain/usecases/sign_out_user.dart';
import 'package:finsync/presentation/pages/profile/profile_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Decide para onde vai quem abre a app.
///
/// Antes esta decisão era uma linha no router: havia sessão, ia para a
/// Home. Só que ter sessão não quer dizer ter conta pronta — quem se
/// registou e fechou a app a meio do tutorial ficava com sessão e sem
/// perfil preenchido, e caía numa Home vazia sem forma de voltar atrás.
/// Reinstalar a app "resolvia" porque apagava a sessão.
///
/// Saber se o tutorial está feito obriga a ler o perfil da base de dados,
/// e isso é assíncrono — daí ser um ecrã e não um `redirect` do go_router,
/// que tem de decidir de forma síncrona.
class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideDestination());
  }

  Future<void> _decideDestination() async {
    if (mounted) setState(() => _error = null);

    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      _goTo('/login');
      return;
    }

    try {
      final users = await sl<GetUser>()();

      if (!mounted) return;

      // Sessão válida mas sem linha em `profiles`: a conta ficou a meio de
      // ser criada. Terminar a sessão é o que desbloqueia a pessoa — é o
      // que a reinstalação fazia, sem ter de reinstalar.
      if (users.isEmpty) {
        await sl<SignOutUser>()();
        _goTo('/login');
        return;
      }

      if (users.first.isFirstLogin) {
        _goTo('/onboarding');
        return;
      }

      context.read<ProfileBloc>().add(LoadProfileEvent());
      _goTo('/home');

      // Depois de navegar, sem esperar: os avisos não podem atrasar a
      // entrada na app, e falhar a agendá-los não é motivo para bloquear
      // ninguém à porta.
      unawaited(_rescheduleNotifications());
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AppErrorTranslator.translate(e));
    }
  }

  Future<void> _rescheduleNotifications() async {
    try {
      await sl<RescheduleNotifications>()();
    } catch (_) {
      // Sem rede ou sem autorização, fica para a próxima abertura.
    }
  }

  void _goTo(String location) {
    if (!mounted) return;
    context.go(location);
  }

  Future<void> _signOutAndRestart() async {
    try {
      await sl<SignOutUser>()();
    } catch (_) {
      // Se nem terminar sessão resulta, o ecrã de login trata do resto.
    }
    _goTo('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: _error == null
                ? const _LoadingIdentity()
                : _StartupError(
                    message: _error!,
                    onRetry: _decideDestination,
                    onSignOut: _signOutAndRestart,
                  ),
          ),
        ),
      ),
    );
  }
}

class _LoadingIdentity extends StatelessWidget {
  const _LoadingIdentity();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: .10),
            borderRadius: AppRadius.all(26),
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            size: 42,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          tr('main_nav.app_name'),
          style: AppTextStyles.headingMedium.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: .4,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

/// Sem rede, ficar preso num círculo a rodar para sempre não ajuda
/// ninguém. Há sempre saída: tentar outra vez ou voltar ao login.
class _StartupError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  const _StartupError({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.textSecondary),
        const SizedBox(height: AppSpacing.lg),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(
          onPressed: onRetry,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            minimumSize: const Size(220, AppSizes.primaryButton),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.all(AppRadius.lg),
            ),
          ),
          icon: const Icon(Icons.refresh_rounded),
          label: Text(tr('common.retry')),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: onSignOut,
          child: Text(tr('profile.logout')),
        ),
      ],
    );
  }
}
