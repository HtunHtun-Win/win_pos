import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/state_manager.dart';
import 'package:jue_pos/user/models/user.dart';
import 'package:jue_pos/user/services/user_service.dart';

class UserController extends GetxController {
  UserService service = UserService();

  var users = [].obs;
  var current_user = {}.obs;
  var edit_user = User.fromMap({}).obs;

  Future<void> getAll() async {
    var datas = await service.getAll();
    users.clear();
    datas.forEach((data) {
      users.add(User.fromMap(data));
    });
  }

  Future<Map> validUser(String loginId,String password) async{
    var data = await service.validUser(loginId,password);
    if(data.length > 0){
      current_user.value = data[0];
      return current_user.value;
    }
    return {};
  }

  Future<int> insertUser(String name,String login_id,String password,int role_id) async{
    var num = await service.insertUser(name, login_id, password, role_id);
    getAll();
    return num;
  }

  Future<int> updateUser(int id,String name,String loginId,String password,int role_id) async{
    return await service.updateUser(id, name, loginId, password, role_id);
  }

  Future<void> deleteUser(int id) async{
    await service.deleteUser(id);
    getAll();
  }
}
