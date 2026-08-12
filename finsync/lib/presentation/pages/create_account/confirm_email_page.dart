import 'package:finsync/core/di/injection.dart';
import 'package:finsync/core/errors/auth_error_translator.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/usecases/resend_confirmation_email.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Ecrã que aparece a seguir ao registo, enquanto o email não é confirmado.
class ConfirmEmailPage extends StatefulWidget {
  final String email;

  const ConfirmEmailPage({super.key, required this.email});

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  bool _isSending = false;

  /// Segundos que faltam até se poder reenviar.
  ///
  /// O servidor limita os reenvios e responde com erro a quem insiste. Um
  /// contador à vista é mais honesto do que deixar carregar e devolver
  /// "demasiadas tentativas".
  int _cooldown = 0;

  Future<void> _resend() async {
    if (_isSending || _cooldown > 0) return;

    setState(() => _isSending = true);

    try {
      await sl<ResendConfirmationEmail>()(widget.email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('confirm_email.resent'))),
      );

      _startCooldown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthErrorTranslator.translate(e)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _startCooldown() {
    setState(() => _cooldown = 60);

    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() => _cooldown--);
      return _cooldown > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: .10),
                      borderRadius: AppRadius.all(28),
                    ),
                    child: Icon(
                      Icons.mark_email_unread_rounded,
                      size: 46,
                      color: AppColors.secondary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    tr('confirm_email.title'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingLarge.copyWith(fontSize: 28),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    tr('confirm_email.subtitle', {'email': widget.email}),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.all(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            tr('confirm_email.spam_hint'),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.primaryButton,
                    child: FilledButton.icon(
                      onPressed: () => context.go('/login'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.all(AppRadius.lg),
                        ),
                      ),
                      icon: const Icon(Icons.login_rounded),
                      label: Text(tr('confirm_email.go_to_login')),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  TextButton(
                    onPressed: (_isSending || _cooldown > 0) ? null : _resend,
                    child: Text(
                      _cooldown > 0
                          ? tr('confirm_email.resend_in', {
                              'seconds': '$_cooldown',
                            })
                          : tr('confirm_email.resend'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
