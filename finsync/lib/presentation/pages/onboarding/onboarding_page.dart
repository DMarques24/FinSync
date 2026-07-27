import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/presentation/pages/onboarding/components/balance_step.dart';
import 'package:finsync/presentation/pages/onboarding/components/features_step.dart';
import 'package:finsync/presentation/pages/onboarding/components/welcome_step.dart';
import 'package:finsync/presentation/pages/onboarding/onboarding_bloc.dart';
import 'package:finsync/presentation/pages/onboarding/onboarding_event.dart';
import 'package:finsync/presentation/pages/onboarding/onboarding_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  final _balanceController = TextEditingController();
  int _currentPage = 0;

  static const _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _submitBalance(BuildContext context) {
    final raw = _balanceController.text.trim().replaceAll(',', '.');
    final balance = double.tryParse(raw);

    if (balance == null || balance < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('onboarding.invalid_balance'))),
      );
      return;
    }

    // O valor escrito está na moeda atualmente selecionada — converte para
    // EUR (moeda-base guardada na BD) antes de submeter.
    context.read<OnboardingBloc>().add(
      OnboardingSubmitBalanceEvent(AppCurrency.toBase(balance)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<OnboardingBloc, OnboardingState>(
            listener: (context, state) {
              if (state is OnboardingLoadedState) {
                context.go('/');
              }
              if (state is OnboardingErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is OnboardingLoadingState;

              return Column(
                children: [
                  // Permite voltar atrás em qualquer passo, exceto no primeiro.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
                    child: SizedBox(
                      height: 44,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _currentPage > 0 ? 1 : 0,
                        child: IgnorePointer(
                          ignoring: _currentPage == 0,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      children: [
                        WelcomeStep(),
                        FeaturesStep(),
                        BalanceStep(
                          controller: _balanceController,
                          isLoading: isLoading,
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_totalPages, (index) {
                            final isActive = index == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: isActive ? 26 : 8,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.secondary
                                    : AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_currentPage < _totalPages - 1) {
                                      _goToNextPage();
                                    } else {
                                      _submitBalance(context);
                                    }
                                  },
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
                                    _currentPage < _totalPages - 1
                                        ? tr('onboarding.next')
                                        : tr('onboarding.finish'),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
