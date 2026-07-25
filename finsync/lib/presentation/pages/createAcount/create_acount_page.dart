import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/createAcount/create_acount_bloc.dart';
import 'package:finsync/presentation/pages/createAcount/create_acount_event.dart';
import 'package:finsync/presentation/pages/createAcount/create_acount_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateAcountPage extends StatefulWidget {
  const CreateAcountPage({super.key});

  @override
  State<CreateAcountPage> createState() => _CreateAcountState();
}

class _CreateAcountState extends State<CreateAcountPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passWordController = TextEditingController();
  final _passWordConfirmController = TextEditingController();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passWordController.dispose();
    _passWordConfirmController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passWordController.text.trim();
    final confirm = _passWordConfirmController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preenche todos os campos.")),
      );
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Indica um email válido.")),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As passwords não coincidem.")),
      );
      return;
    }

    context.read<CreateAcountBloc>().add(
      CreateAcountSubmitEvent(username: username, email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<CreateAcountBloc, CreateAcountState>(
          listener: (context, state) {
            if (state is CreateAcountLoadedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Conta criada com sucesso!"),
                  backgroundColor: AppColors.success,
                ),
              );
              context.go('/login');
            }
            if (state is CreateAcountErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is CreateAcountLoadingState;

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
                          Icons.person_add_alt_1_rounded,
                          size: 44,
                          color: AppColors.secondary,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        "Criar conta 🚀",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingLarge,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Cria a tua conta para começar",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 36),

                      TextFormField(
                        controller: _usernameController,
                        enabled: !isLoading,
                        maxLength: 25,
                        style: AppTextStyles.bodyMedium,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(25),
                        ],
                        decoration: InputDecoration(
                          labelText: "Nome de utilizador",
                          counterText: "",
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      TextFormField(
                        controller: _emailController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          labelText: "Email",
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
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.secondary,
                          ),
                          suffixIcon: IconButton(
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

                      const SizedBox(height: 18),

                      TextFormField(
                        controller: _passWordConfirmController,
                        enabled: !isLoading,
                        obscureText: _obscureConfirmPassword,
                        style: AppTextStyles.bodyMedium,
                        onFieldSubmitted: (_) =>
                            isLoading ? null : _submit(context),
                        decoration: InputDecoration(
                          labelText: "Confirmar password",
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.secondary,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
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
                              : const Text(
                                  "Criar conta",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Já tens conta?",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.go('/login'),
                            child: const Text("Fazer login"),
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
