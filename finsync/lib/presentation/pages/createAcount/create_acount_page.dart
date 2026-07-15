import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/presentation/pages/createAcount/create_acount_bloc.dart';
import 'package:finsync/presentation/pages/createAcount/create_acount_event.dart';
import 'package:finsync/presentation/pages/createAcount/create_acount_state.dart';
import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passWordController.dispose();
    _passWordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<CreateAcountBloc, CreateAcountState>(
          listener: (context, state) {
            if (state is CreateAcountLoadedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Conta criada com sucesso!"),
                  backgroundColor: Colors.green,
                ),
              );
              context.go('/login');
            }
            if (state is CreateAcountErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is CreateAcountLoadingState;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Criar Conta 🚀",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Cria a tua conta para começar",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 40),

                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Nome de utilizador",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _passWordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _passWordConfirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirmar Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final username = _usernameController.text.trim();
                              final email = _emailController.text.trim();
                              final password = _passWordController.text.trim();
                              final confirm = _passWordConfirmController.text
                                  .trim();

                              if (username.isEmpty ||
                                  email.isEmpty ||
                                  password.isEmpty ||
                                  confirm.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Preenche todos os campos."),
                                  ),
                                );
                                return;
                              }

                              if (password != confirm) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "As passwords não coincidem.",
                                    ),
                                  ),
                                );
                                return;
                              }

                              context.read<CreateAcountBloc>().add(
                                CreateAcountSubmitEvent(
                                  email: email,
                                  password: password,
                                  username: username,
                                ),
                              );
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
                              "Criar Conta",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: const Text("Já tens conta? Fazer Login"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
