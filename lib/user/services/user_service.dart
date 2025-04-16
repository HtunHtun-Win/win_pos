import 'package:win_pos/user/repository/user_repository.dart';

class UserService {
  UserRepository userRepo = UserRepository();

  Future<List> getAll() async {
    return await userRepo.getAll();
  }

  Future<List> validUser(String loginId, String password) async {
    var datas = await userRepo.validUser(loginId, password);
    if (datas.isNotEmpty) {
      return datas;
    } else {
      return [];
    }
  }

  Future<int> insertUser(
      String name, String loginId, String password, int roleId) async {
    var data = await validUser(loginId, password);
    if (data.isNotEmpty) {
      return -1;
    } else if (name.length >= 2 &&
        loginId.length >= 2 &&
        password.length >= 2 &&
        roleId != null) {
      return await userRepo.insertUser(name, loginId, password, roleId);
    } else {
      return 0;
    }
  }

  Future<int> updateUser(
      int id, String name, String loginId, String password, int roleId) async {
    var data = await userRepo.getByName(loginId);
    if (data.isEmpty || data[0]['id'] == id) {
      if (name.length >= 2 &&
          loginId.length >= 2 &&
          password.length >= 2 &&
          roleId != null) {
        await userRepo.updateUser(id, name, loginId, password, roleId);
        return 1;
      } else {
        return 0;
      }
    }
    return 0;
  }

  Future<void> deleteUser(int id) async {
    await userRepo.deleteUser(id);
  }
}
