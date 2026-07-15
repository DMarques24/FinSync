abstract class CreateAcountEvent {}

class CreateAcountSubmitEvent extends CreateAcountEvent {
  final String email;
  final String password;
  final String username;

  CreateAcountSubmitEvent({
    required this.email,
    required this.password,
    required this.username,
  });
}
