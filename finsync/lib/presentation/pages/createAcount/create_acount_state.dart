abstract class CreateAcountState {}

class CreateAcountInitialState extends CreateAcountState {}

class CreateAcountLoadingState extends CreateAcountState {}

class CreateAcountLoadedState extends CreateAcountState {}

class CreateAcountErrorState extends CreateAcountState {
  final String message;

  CreateAcountErrorState(this.message);
}
