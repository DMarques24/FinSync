abstract class OnboardingEvent {}

class OnboardingSubmitBalanceEvent extends OnboardingEvent {
  final double balance;

  OnboardingSubmitBalanceEvent(this.balance);
}
