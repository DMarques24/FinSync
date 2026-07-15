import 'package:finsync/domain/entities/user.dart';
import 'package:finsync/domain/repositories/user_repository.dart';

class GetUser {
  final UserRepository userRepository;

  GetUser(this.userRepository);

  Future<List<User>> call() async {
    return await userRepository.getUser();
  }
}
