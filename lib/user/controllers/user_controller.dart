import 'dart:math';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/state_manager.dart';
import 'package:jue_pos/user/models/user.dart';
import 'package:jue_pos/user/screens/user_screen.dart';
import 'package:jue_pos/user/services/user_service.dart';

class UserController extends GetxController {
  UserService service = UserService();

  var users = [].obs;

  Future<void> getAll() async {
    var datas = await service.getAll();
    users.clear();
    datas.forEach((data) {
      users.add(User.fromMap(data));
    });
  }

  Future<bool> validUser(String loginId,String password) async{
    var isValid = await service.validUser(loginId,password);
    return isValid;
  }

}
