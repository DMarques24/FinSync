import 'package:finsync/core/di/injection.dart';
import 'package:finsync/core/errors/auth_error_translator.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/usecases/recover_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Recuperação de password em dois passos, no mesmo ecrã.
///
/// Primeiro pede-se o email, depois o código de seis dígitos e a password
/// nova. Ficam juntos de propósito: quem escreve o email tem o código no
/// telemóvel segundos depois, e mudar de ecrã pelo meio só dá a sensação
/// de que o processo é mais longo do que é.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

enum _Step { askEmail, askCode }

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  _Step _step = _Step.askEmail;
  bool _isBusy = false;
  bool _obscure = true;
  String? _error;

  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Validação ──────────────────────────────────────────────────────

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return tr('forgot.error_email_required');
    if (!_emailRegex.hasMatch(email)) return tr('forgot.error_email_invalid');
    return null;
  }

  String? _validateCode(String? value) {
    final code = (value ?? '').trim();
    if (code.isEmpty) return tr('forgot.error_code_required');
    if (code.length < 6) return tr('forgot.error_code_short');
    return null;
  }

  /// As mesmas regras do ecrã de segurança. Ter duas ideias diferentes do
  /// que é uma password aceitável na mesma app seria confuso.
  String? _validatePassword(String? value) {
    final password = (value ?? '').trim();

    if (password.isEmpty) return tr('security.error_new_required');
    if (password.length < 8) return tr('security.error_too_short');
    if (!RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(password)) {
      return tr('security.error_needs_letter');
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return tr('security.error_needs_number');
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    final confirm = (value ?? '').trim();
    if (confirm.isEmpty) return tr('security.error_confirm_required');
    if (confirm != _passwordController.text.trim()) {
      return tr('security.error_mismatch');
    }
    return null;
  }

  // ── Ações ──────────────────────────────────────────────────────────

  Future<void> _sendCode() async {
    setState(() {
      _autovalidate = AutovalidateMode.onUserInteraction;
      _error = null;
    });

    if (_validateEmail(_emailController.text) != null) {
      _formKey.currentState?.validate();
      return;
    }

    setState(() => _isBusy = true);

    try {
      await sl<RecoverPassword>().sendCode(_emailController.text.trim());

      if (!mounted) return;
      setState(() {
        _step = _Step.askCode;
        _autovalidate = AutovalidateMode.disabled;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AuthErrorTranslator.translate(e));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _confirm() async {
    setState(() {
      _autovalidate = AutovalidateMode.onUserInteraction;
      _error = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isBusy = true);

    try {
      final recover = sl<RecoverPassword>();

      await recover.verifyCode(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
      );

      await recover.setNewPassword(_passwordController.text.trim());

      if (!mounted) return;

      // O `verifyOTP` deixou uma sessão aberta. Mandar a pessoa entrar com
      // a password nova confirma que ela ficou como queria — e evita
      // deixá-la dentro da app por uma via que não foi um login.
      final messenger = ScaffoldMessenger.of(context);
      context.go('/login');
      messenger.showSnackBar(
        SnackBar(content: Text(tr('forgot.changed'))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AuthErrorTranslator.translate(e));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAskingCode = _step == _Step.askCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/login'),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            0,
            AppSpacing.xxl,
            AppSpacing.xxxl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: .10),
                      borderRadius: AppRadius.all(26),
                    ),
                    child: Icon(
                      isAskingCode
                          ? Icons.mark_email_read_rounded
                          : Icons.lock_reset_rounded,
                      size: 42,
                      color: AppColors.secondary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    tr(
                      isAskingCode ? 'forgot.code_title' : 'forgot.email_title',
                    ),
                    style: AppTextStyles.headingLarge.copyWith(height: 1.15),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    isAskingCode
                        ? tr('forgot.code_subtitle', {
                            'email': _emailController.text.trim(),
                          })
                        : tr('forgot.email_subtitle'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  if (_error != null) ...[
                    _ErrorBanner(message: _error!),
                    const SizedBox(height: 18),
                  ],

                  TextFormField(
                    controller: _emailController,
                    // Depois de enviado, o email deixa de se poder mudar
                    // aqui: o código que chegou é daquele endereço.
                    enabled: !_isBusy && !isAskingCode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: _validateEmail,
                    onFieldSubmitted: (_) => _isBusy ? null : _sendCode(),
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      labelText: tr('login.email_label'),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),

                  if (isAskingCode) ...[
                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _codeController,
                      enabled: !_isBusy,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      maxLength: 6,
                      validator: _validateCode,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: AppTextStyles.headingMedium.copyWith(
                        fontSize: 24,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        labelText: tr('forgot.code_label'),
                        counterText: '',
                        prefixIcon: Icon(
                          Icons.pin_rounded,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isBusy,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.next,
                      validator: _validatePassword,
                      onChanged: (_) {
                        if (_autovalidate == AutovalidateMode.disabled) return;
                        _formKey.currentState?.validate();
                      },
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        labelText: tr('security.new_label'),
                        helperText: tr('security.requirements'),
                        helperMaxLines: 2,
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.secondary,
                        ),
                        suffixIcon: IconButton(
                          tooltip: tr('common.toggle_password'),
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
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
                      enabled: !_isBusy,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      validator: _validateConfirm,
                      onFieldSubmitted: (_) => _isBusy ? null : _confirm(),
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        labelText: tr('security.confirm_label'),
                        prefixIcon: Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.primaryButton,
                    child: FilledButton(
                      onPressed: _isBusy
                          ? null
                          : (isAskingCode ? _confirm : _sendCode),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.all(AppRadius.lg),
                        ),
                      ),
                      child: _isBusy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              tr(
                                isAskingCode
                                    ? 'forgot.confirm'
                                    : 'forgot.send_code',
                              ),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  if (isAskingCode) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: TextButton(
                        onPressed: _isBusy
                            ? null
                            : () => setState(() {
                                _step = _Step.askEmail;
                                _error = null;
                                _codeController.clear();
                              }),
                        child: Text(tr('forgot.wrong_email')),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: .10),
        borderRadius: AppRadius.all(AppRadius.sm),
        border: Border.all(color: AppColors.error.withValues(alpha: .35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
