import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:win_pos/user/models/user.dart';
import 'package:win_pos/user/services/user_service.dart';

class UserController extends GetxController {
  UserService service = UserService();

  var users = [].obs;
  var current_user = {}.obs;
  var edit_user = User.fromMap({}).obs;

  Future<void> getAll() async {
    var datas = await service.getAll();
    users.clear();
    for (var data in datas) {
      users.add(User.fromMap(data));
    }
  }

  void setCurrentUser(data){
    current_user.value = data;
  }

  Future<Map> validUser(String loginId, String password) async {
    var data = await service.validUser(loginId, password);
    if (data.isNotEmpty) {
      current_user.value = data[0];
      // ignore: invalid_use_of_protected_member
      return current_user.value;
    }
    return {};
  }

  Future<int> insertUser(
      String name, String loginId, String password, int roleId) async {
    var num = await service.insertUser(name, loginId, password, roleId);
    getAll();
    return num;
  }

  Future<int> updateUser(
      int id, String name, String loginId, String password, int roleId) async {
    var num = await service.updateUser(id, name, loginId, password, roleId);
    getAll();
    return num;
  }

  Future<void> deleteUser(int id) async {
    await service.deleteUser(id);
    getAll();
  }
}
