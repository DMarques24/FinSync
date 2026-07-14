import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/presentation/pages/createAcount/create_acount_bloc.dart';
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
  final _userNameController = TextEditingController();
  final _userEmailController = TextEditingController();
  final _passWordController = TextEditingController();
  final _passWordConfirmController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CreateAcountBloc, CreateAcountState>(
          builder: (context, state) {
            if (state is CreateAcountLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CreateAcountErrorState) {
              return Center(child: Text(state.message));
            }

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
                    "Bem-vindo 👋",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Cria a sua conta",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 40),

                  TextFormField(
                    controller: _userNameController,
                    decoration: InputDecoration(
                      labelText: "User name",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _userEmailController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.lock_outline),
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
                      labelText: "password",
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
                      labelText: "password confirm",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Criar Conta",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      context.go('login');
                    },
                    child: const Text("Fazer Login"),
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
