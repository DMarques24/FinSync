import 'package:finsync/core/errors/app_error_translator.dart';
import 'package:finsync/domain/usecases/complete_onboarding.dart';
import 'package:finsync/presentation/pages/onboarding/onboarding_event.dart';
import 'package:finsync/presentation/pages/onboarding/onboarding_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final CompleteOnboarding completeOnboarding;

  OnboardingBloc(this.completeOnboarding) : super(OnboardingInitialState()) {
    on<OnboardingSubmitBalanceEvent>(_onSubmitBalance);
  }

  Future<void> _onSubmitBalance(
    OnboardingSubmitBalanceEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoadingState());
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilizador não autenticado.');
      }
      await completeOnboarding(userId, event.balance);
      emit(OnboardingLoadedState());
    } catch (e) {
      emit(OnboardingErrorState(AppErrorTranslator.translate(e)));
    }
  }
}
