abstract class CreateAcountEvent {}

class CreateAcountSubmitEvent extends CreateAcountEvent {
  final String email;
  final String password;

  CreateAcountSubmitEvent({required this.email, required this.password});
}
