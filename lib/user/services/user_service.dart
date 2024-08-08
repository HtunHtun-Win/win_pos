import 'package:jue_pos/user/repository/user_repository.dart';

class UserService {
  UserRepository userRepo = UserRepository();

  Future<List> getAll() async {
    return await userRepo.getAll();
  }

  Future<Map<String,dynamic>> validUser(String loginId,String password) async{
    var datas = await userRepo.validUser(loginId,password);
    if(datas.isNotEmpty){
      return datas[0];
    }else{
      return {};
    }
}
}
