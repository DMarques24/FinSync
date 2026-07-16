abstract class CreateAcountEvent {}

class CreateAcountSubmitEvent extends CreateAcountEvent {
  final String username;
  final String email;
  final String password;

  CreateAcountSubmitEvent({
    required this.username,
    required this.email,
    required this.password,
  });
}
