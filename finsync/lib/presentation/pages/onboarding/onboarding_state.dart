abstract class OnboardingState {}

class OnboardingInitialState extends OnboardingState {}

class OnboardingLoadingState extends OnboardingState {}

class OnboardingLoadedState extends OnboardingState {}

class OnboardingErrorState extends OnboardingState {
  final String message;

  OnboardingErrorState(this.message);
}
