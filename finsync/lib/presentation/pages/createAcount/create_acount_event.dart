abstract class CreateAcountEvent {}

class CreateAcountSubmitEvent extends CreateAcountEvent {
  final String email;
  final String password;
  final String userName;

  CreateAcountSubmitEvent({
    required this.email,
    required this.password,
    required this.userName,
  });
}
