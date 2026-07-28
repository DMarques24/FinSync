abstract class CreateAccountEvent {}

class CreateAccountSubmitEvent extends CreateAccountEvent {
  final String username;
  final String email;
  final String password;

  CreateAccountSubmitEvent({
    required this.username,
    required this.email,
    required this.password,
  });
}
