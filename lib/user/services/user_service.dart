import 'package:jue_pos/user/repository/user_repository.dart';

class UserService {
  UserRepository userRepo = UserRepository();

  Future<List> getAll() async {
    return await userRepo.getAll();
  }
}
