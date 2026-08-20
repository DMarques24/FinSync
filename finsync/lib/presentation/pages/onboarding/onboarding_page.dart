import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/core/currency/currency_bloc.dart';
import 'package:finsync/core/currency/currency_event.dart';
import 'package:finsync/presentation/pages/onboarding/components/balance_step.dart';
import 'package:finsync/presentation/pages/onboarding/components/currency_step.dart';
import 'package:finsync/presentation/pages/onboarding/components/features_step.dart';
import 'package:finsync/presentation/pages/onboarding/components/income_step.dart';
import 'package:finsync/presentation/pages/onboarding/components/welcome_step.dart';
import 'package:finsync/presentation/pages/onboarding/onboarding_bloc.dart';
import 'package:finsync/presentation/pages/onboarding/onboarding_event.dart';
import 'package:finsync/presentation/pages/onboarding/onboarding_state.dart';
import 'package:finsync/presentation/pages/profile/profile_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _balanceFocusNode = FocusNode();

  final _incomeController = TextEditingController();
  final _incomeFocusNode = FocusNode();

  AppCurrencyType _currency = AppCurrency.type;

  int _currentPage = 0;

  /// Ordem: boas-vindas, funcionalidades, moeda, saldo, rendimento.
  ///
  /// A moeda vem antes de qualquer valor de propósito — senão quem não usa
  /// euro escreve o primeiro número na moeda errada. Só os passos com
  /// comportamento próprio têm constante; os dois primeiros são só ecrãs.
  static const _pageBalance = 3;
  static const _pageIncome = 4;

  static const _totalPages = 5;
  static const _lastPage = _totalPages - 1;
  static const _pageTransition = Duration(milliseconds: 320);

  @override
  void dispose() {
    _pageController.dispose();
    _balanceController.dispose();
    _balanceFocusNode.dispose();
    _incomeController.dispose();
    _incomeFocusNode.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      page,
      duration: _pageTransition,
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);

    // O teclado só abre no passo que tem campo, e depois da animação —
    // pedir foco a meio do deslize fazia a transição saltar.
    _balanceFocusNode.unfocus();
    _incomeFocusNode.unfocus();

    if (index == _pageBalance) _balanceFocusNode.requestFocus();
    if (index == _pageIncome) _incomeFocusNode.requestFocus();
  }

  void _changeCurrency(AppCurrencyType currency) {
    setState(() => _currency = currency);

    // Aplicada de imediato para os passos seguintes já mostrarem o
    // símbolo certo nos campos.
    context.read<CurrencyBloc>().add(ChangeCurrencyEvent(currency));
  }

  double? _parse(TextEditingController controller) {
    final raw = controller.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  void _submit(BuildContext context) {
    final balance = _parse(_balanceController);
    final income = _parse(_incomeController);

    if (balance == null || balance < 0) {
      _showMessage(context, tr('onboarding.invalid_balance'));
      _goTo(_pageBalance);
      return;
    }

    // O rendimento pode ficar em branco: quem trabalha a recibos verdes ou
    // vive de rendimentos variáveis não tem um número para dar, e obrigar
    // a inventar um só estragava as contas.
    if (income != null && income < 0) {
      _showMessage(context, tr('onboarding.invalid_income'));
      return;
    }

    _balanceFocusNode.unfocus();
    _incomeFocusNode.unfocus();
    HapticFeedback.mediumImpact();

    context.read<OnboardingBloc>().add(
      OnboardingSubmitEvent(
        // Os valores estão na moeda escolhida; a base de dados guarda
        // tudo em euros.
        balance: AppCurrency.toBase(balance),
        monthlyIncome: AppCurrency.toBase(income ?? 0),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.all(AppRadius.md),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocConsumer<OnboardingBloc, OnboardingState>(
            listener: (context, state) {
              if (state is OnboardingLoadedState) {
                // O saldo acabou de ser escrito na base de dados. O perfil
                // em memória ainda é o de antes do onboarding, por isso tem
                // de ser relido antes de a Home o ir buscar.
                context.read<ProfileBloc>().add(LoadProfileEvent());
                context.go('/home');
              }
              if (state is OnboardingErrorState) {
                _showMessage(context, state.message);
              }
            },
            builder: (context, state) {
              final isLoading = state is OnboardingLoadingState;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: Column(
                  children: [
                    _TopBar(
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                      isLoading: isLoading,
                      onBack: () => _goTo(_currentPage - 1),
                      onSkip: () => _goTo(_lastPage),
                    ),

                    _ProgressBar(
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                    ),

                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        physics: isLoading
                            ? const NeverScrollableScrollPhysics()
                            : null,
                        children: [
                          const WelcomeStep(),
                          const FeaturesStep(),
                          CurrencyStep(
                            selected: _currency,
                            enabled: !isLoading,
                            onChanged: _changeCurrency,
                          ),
                          BalanceStep(
                            controller: _balanceController,
                            focusNode: _balanceFocusNode,
                            isLoading: isLoading,
                            // Ainda não é o último passo: avança em vez de
                            // submeter.
                            onSubmitted: () => _goTo(_pageIncome),
                          ),
                          IncomeStep(
                            controller: _incomeController,
                            focusNode: _incomeFocusNode,
                            isLoading: isLoading,
                            onSubmitted: () => _submit(context),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        AppSpacing.lg,
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                      ),
                      child: _PrimaryButton(
                        // Só o saldo é obrigatório. O rendimento pode ficar
                        // em branco, por isso o último passo não precisa de
                        // travar o botão.
                        requiredField: _currentPage == _pageBalance
                            ? _balanceController
                            : null,
                        isLastPage: _currentPage == _lastPage,
                        isLoading: isLoading,
                        onPressed: () {
                          if (_currentPage < _lastPage) {
                            _goTo(_currentPage + 1);
                          } else {
                            _submit(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _TopBar({
    required this.currentPage,
    required this.totalPages,
    required this.isLoading,
    required this.onBack,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final canGoBack = currentPage > 0 && !isLoading;
    final canSkip = currentPage < totalPages - 1 && !isLoading;

    return SizedBox(
      height: AppSizes.minTouchTarget,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          children: [
            _FadeAction(
              visible: canGoBack,
              child: IconButton(
                onPressed: onBack,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: Text(
                  tr('onboarding.step_of', {
                    'current': '${currentPage + 1}',
                    'total': '$totalPages',
                  }),
                  style: AppTextStyles.labelSmall,
                ),
              ),
            ),

            _FadeAction(
              visible: canSkip,
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  minimumSize: const Size(
                    AppSizes.minTouchTarget,
                    AppSizes.minTouchTarget,
                  ),
                ),
                child: Text(
                  tr('onboarding.skip'),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FadeAction extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _FadeAction({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: visible ? 1 : 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: ExcludeSemantics(excluding: !visible, child: child),
      ),
    );
  }
}


class _ProgressBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _ProgressBar({required this.currentPage, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.sm,
        AppSpacing.xxl,
        0,
      ),
      child: Row(
        children: List.generate(totalPages, (index) {
          final isDone = index <= currentPage;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              height: 4,
              margin: EdgeInsets.only(
                right: index == totalPages - 1 ? 0 : AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isDone ? AppColors.secondary : AppColors.border,
                borderRadius: AppRadius.all(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  /// Campo que tem de estar preenchido para o botão funcionar. `null` nos
  /// passos sem nada obrigatório — e é isso que faz o botão ficar sempre
  /// ativo neles.
  final TextEditingController? requiredField;

  final bool isLastPage;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.requiredField,
    required this.isLastPage,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final field = requiredField;

    if (field == null) return _button(enabled: !isLoading);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: field,
      builder: (context, value, _) {
        return _button(enabled: !isLoading && value.text.trim().isNotEmpty);
      },
    );
  }

  Widget _button({required bool enabled}) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.primaryButton,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.all(AppRadius.lg),
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
                isLastPage ? tr('onboarding.finish') : tr('onboarding.next'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
