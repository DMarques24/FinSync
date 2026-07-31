import 'package:finsync/core/di/injection.dart';
import 'package:finsync/core/errors/auth_error_translator.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/usecases/change_password.dart';
import 'package:flutter/material.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  /// Só passa a validar continuamente depois da primeira tentativa. Marcar
  /// o campo a vermelho enquanto a pessoa ainda está a escrever a primeira
  /// letra é hostil.
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateCurrent(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return tr('security.error_current_required');
    }
    return null;
  }

  String? _validateNew(String? value) {
    final password = (value ?? '').trim();

    if (password.isEmpty) return tr('security.error_new_required');

    // Uma regra de cada vez, pela ordem em que a pessoa a vai resolver.
    // Despejar "8 caracteres, uma letra e um número" de uma só vez quando
    // falta apenas o número faz perder tempo a reler tudo.
    if (password.length < 8) return tr('security.error_too_short');

    if (!RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(password)) {
      return tr('security.error_needs_letter');
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      return tr('security.error_needs_number');
    }

    if (password == _currentController.text.trim()) {
      return tr('security.error_same_as_current');
    }

    return null;
  }

  String? _validateConfirm(String? value) {
    final confirm = (value ?? '').trim();

    if (confirm.isEmpty) return tr('security.error_confirm_required');
    if (confirm != _newController.text.trim()) {
      return tr('security.error_mismatch');
    }

    return null;
  }

  Future<void> _submit() async {
    if (_isSaving) return;

    // A partir daqui os campos corrigem-se sozinhos à medida que a pessoa
    // escreve, sem ter de carregar no botão outra vez para ver se acertou.
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      await sl<ChangePassword>()(
        currentPassword: _currentController.text.trim(),
        newPassword: _newController.text.trim(),
      );

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text(tr('security.changed'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthErrorTranslator.translate(e)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.lg),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: Column(
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.disabled,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: .10),
                        borderRadius: AppRadius.all(AppRadius.md),
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.secondary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('security.title'),
                            style: AppTextStyles.headingMedium.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr('security.subtitle'),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                TextFormField(
                  controller: _currentController,
                  enabled: !_isSaving,
                  obscureText: _obscureCurrent,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyMedium,
                  validator: _validateCurrent,
                  decoration: InputDecoration(
                    labelText: tr('security.current_label'),
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.secondary,
                    ),
                    suffixIcon: _VisibilityToggle(
                      obscured: _obscureCurrent,
                      onPressed: () => setState(() {
                        _obscureCurrent = !_obscureCurrent;
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _newController,
                  enabled: !_isSaving,
                  obscureText: _obscureNew,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyMedium,
                  validator: _validateNew,
                  // Revalida a confirmação: se a nova password mudar depois
                  // de já estarem iguais, o erro tem de reaparecer.
                  onChanged: (_) {
                    if (_autovalidate != AutovalidateMode.disabled) {
                      _formKey.currentState?.validate();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: tr('security.new_label'),
                    helperText: tr('security.requirements'),
                    helperMaxLines: 2,
                    prefixIcon: Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.secondary,
                    ),
                    suffixIcon: _VisibilityToggle(
                      obscured: _obscureNew,
                      onPressed: () => setState(() {
                        _obscureNew = !_obscureNew;
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _confirmController,
                  enabled: !_isSaving,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.bodyMedium,
                  validator: _validateConfirm,
                  onFieldSubmitted: (_) => _isSaving ? null : _submit(),
                  decoration: InputDecoration(
                    labelText: tr('security.confirm_label'),
                    prefixIcon: Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.secondary,
                    ),
                    suffixIcon: _VisibilityToggle(
                      obscured: _obscureConfirm,
                      onPressed: () => setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(
                      double.infinity,
                      AppSizes.primaryButton,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.all(AppRadius.lg),
                    ),
                  ),
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(tr('security.submit')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  final bool obscured;
  final VoidCallback onPressed;

  const _VisibilityToggle({required this.obscured, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tr('common.toggle_password'),
      onPressed: onPressed,
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColors.textSecondary,
      ),
    );
  }
}
