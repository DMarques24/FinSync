import 'package:finsync/core/di/injection.dart';
import 'package:finsync/core/errors/auth_error_translator.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/usecases/change_password.dart';
import 'package:flutter/material.dart';


class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;

    final current = _currentController.text.trim();
    final newPassword = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preenche todos os campos.")),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A nova password deve ter pelo menos 6 caracteres."),
        ),
      );
      return;
    }

    if (newPassword != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As passwords não coincidem.")),
      );
      return;
    }

    if (newPassword == current) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A nova password tem de ser diferente da atual."),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await sl<ChangePassword>()(
        currentPassword: current,
        newPassword: newPassword,
      );

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Password alterada com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthErrorTranslator.translate(e))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
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

              const SizedBox(height: 24),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(16),
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
                          "Segurança",
                          style: AppTextStyles.headingMedium.copyWith(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Atualiza a password da tua conta.",
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
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  labelText: "Password atual",
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.secondary,
                  ),
                  suffixIcon: IconButton(
                    tooltip: tr('common.toggle_password'),
                    onPressed: () => setState(() {
                      _obscureCurrent = !_obscureCurrent;
                    }),
                    icon: Icon(
                      _obscureCurrent
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _newController,
                enabled: !_isSaving,
                obscureText: _obscureNew,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  labelText: "Nova password",
                  prefixIcon: Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.secondary,
                  ),
                  suffixIcon: IconButton(
                    tooltip: tr('common.toggle_password'),
                    onPressed: () => setState(() {
                      _obscureNew = !_obscureNew;
                    }),
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _confirmController,
                enabled: !_isSaving,
                obscureText: _obscureConfirm,
                style: AppTextStyles.bodyMedium,
                onFieldSubmitted: (_) => _isSaving ? null : _submit(),
                decoration: InputDecoration(
                  labelText: "Confirmar nova password",
                  prefixIcon: Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.secondary,
                  ),
                  suffixIcon: IconButton(
                    tooltip: tr('common.toggle_password'),
                    onPressed: () => setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    }),
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
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
                label: const Text("Alterar password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
