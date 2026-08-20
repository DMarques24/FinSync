import 'dart:async';

import 'package:finsync/core/di/injection.dart';
import 'package:finsync/core/errors/app_error_translator.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/usecases/delete_account.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Apagar a conta, com confirmação escrita.
///
/// Pede-se para escrever uma palavra em vez de um simples "tens a certeza":
/// isto apaga tudo e não há como voltar atrás. Um botão que se carrega por
/// engano não pode ter esta consequência.
class DeleteAccountSheet extends StatefulWidget {
  const DeleteAccountSheet({super.key});

  @override
  State<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<DeleteAccountSheet> {
  final _controller = TextEditingController();

  bool _isDeleting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isConfirmed =>
      _controller.text.trim().toUpperCase() ==
      tr('delete_account.confirm_word').toUpperCase();

  Future<void> _delete() async {
    if (_isDeleting || !_isConfirmed) return;

    setState(() {
      _isDeleting = true;
      _error = null;
    });

    try {
      await sl<DeleteAccount>()().timeout(const Duration(seconds: 20));

      if (!mounted) return;

      // A sessão já foi terminada pelo caso de uso. Ir para o login por
      // `go` e não `push` limpa a pilha — não pode haver forma de voltar
      // atrás para ecrãs de uma conta que já não existe.
      context.go('/login');
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _error = tr('desire.operation_timeout'));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AppErrorTranslator.translate(e));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xl,
          AppSpacing.xxl,
          MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.disabled,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: .10),
                      borderRadius: AppRadius.all(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.delete_forever_rounded,
                      color: AppColors.error,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      tr('delete_account.title'),
                      style: AppTextStyles.headingMedium.copyWith(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                tr('delete_account.warning'),
                style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
              ),

              const SizedBox(height: AppSpacing.md),

              // Enumerar o que desaparece é mais honesto do que um aviso
              // vago — a pessoa devia saber exatamente o que vai perder.
              for (final item in const [
                'delete_account.item_expenses',
                'delete_account.item_goals',
                'delete_account.item_events',
                'delete_account.item_profile',
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.remove_circle_outline_rounded,
                        size: 15,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          tr(item),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                tr('delete_account.type_to_confirm', {
                  'word': tr('delete_account.confirm_word'),
                }),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              TextField(
                controller: _controller,
                enabled: !_isDeleting,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() => _error = null),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  errorText: _error,
                  hintText: tr('delete_account.confirm_word'),
                  prefixIcon: Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              FilledButton.icon(
                onPressed: (_isDeleting || !_isConfirmed) ? null : _delete,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.disabled,
                  disabledForegroundColor: Colors.white,
                  minimumSize: const Size(
                    double.infinity,
                    AppSizes.primaryButton,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.all(AppRadius.lg),
                  ),
                ),
                icon: _isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete_forever_rounded),
                label: Text(tr('delete_account.confirm')),
              ),

              const SizedBox(height: AppSpacing.sm),

              Center(
                child: TextButton(
                  onPressed: _isDeleting
                      ? null
                      : () => Navigator.pop(context),
                  child: Text(tr('common.cancel')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
