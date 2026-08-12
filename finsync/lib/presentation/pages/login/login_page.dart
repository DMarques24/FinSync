import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/login/login_bloc.dart';
import 'package:finsync/presentation/pages/login/login_event.dart';
import 'package:finsync/presentation/pages/login/login_state.dart';
import 'package:finsync/presentation/pages/home/home_bloc.dart';
import 'package:finsync/presentation/pages/home/home_event.dart';
import 'package:finsync/presentation/pages/profile/profile_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userNameController = TextEditingController();
  final _passWordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _userNameController.dispose();
    _passWordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final email = _userNameController.text.trim();
    final password = _passWordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('login.fill_fields'))),
      );
      return;
    }

    context.read<LoginBloc>().add(
      LoginSubmitEvent(email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginLoadedState) {
              // Os blocos globais foram criados no arranque, quando ainda
              // não havia sessão. Agora que há, os dados deste utilizador
              // têm de ser carregados de raiz.
              context.read<ProfileBloc>().add(LoadProfileEvent());
              context.read<HomeBloc>().add(GetAllExpensesEvent());

              if (state.isFirstLogin) {
                context.go('/onboarding');
              } else {
                context.go('/home');
              }
            }
            if (state is LoginErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is LoginLoadingState;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 46,
                          color: AppColors.secondary,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        tr('login.title'),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingLarge,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        tr('login.subtitle'),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 36),

                      TextFormField(
                        controller: _userNameController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          labelText: tr('login.email_label'),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextFormField(
                        controller: _passWordController,
                        enabled: !isLoading,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        style: AppTextStyles.bodyMedium,
                        onFieldSubmitted: (_) =>
                            isLoading ? null : _submit(context),
                        decoration: InputDecoration(
                          labelText: tr('login.password_label'),
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.secondary,
                          ),
                          suffixIcon: IconButton(
                            tooltip: tr('common.toggle_password'),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: FilledButton(
                          onPressed: isLoading ? null : () => _submit(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  tr('login.submit'),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.push('/forgot-password'),
                          child: Text(tr('login.forgot_password')),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tr('login.no_account'),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.go('/create-account'),
                            child: Text(tr('login.create_account')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
