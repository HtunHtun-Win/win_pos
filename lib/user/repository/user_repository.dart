import 'dart:math';

import 'package:jue_pos/core/database/db_helper.dart';

class UserRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getAll() async {
    final database = await dbObj.database;
    return await database.query("users");
  }

  Future<List> validUser(String loginId,String password) async{
    final database = await dbObj.database;
    return await database.query("users",where: "login_id=? AND password=? AND isactive=?",whereArgs: [loginId,password,0]);
  }
}
