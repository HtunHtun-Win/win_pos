import 'package:jue_pos/user/repository/user_repository.dart';

class UserService {
  UserRepository userRepo = UserRepository();

  Future<List> getAll() async {
    return await userRepo.getAll();
  }

  Future<bool> validUser(String loginId,String password) async{
    var datas = await userRepo.validUser(loginId,password);
    if(datas.isNotEmpty){
      return true;
    }else{
      return false;
    }
}
}
