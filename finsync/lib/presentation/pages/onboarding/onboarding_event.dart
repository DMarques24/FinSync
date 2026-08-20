abstract class OnboardingEvent {}

/// Conclusão do tutorial. Ambos os valores chegam já em euros — a
/// conversão da moeda escolhida é feita no ecrã, antes de submeter.
class OnboardingSubmitEvent extends OnboardingEvent {
  final double balance;
  final double monthlyIncome;

  OnboardingSubmitEvent({
    required this.balance,
    required this.monthlyIncome,
  });
}
