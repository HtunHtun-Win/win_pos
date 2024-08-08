import 'dart:math';

import 'package:jue_pos/core/database/db_helper.dart';

class UserRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getAll() async {
    final database = await dbObj.database;
    return await database.query("users",where: "isdeleted=0");
  }

  Future<List> validUser(String loginId,String password) async{
    final database = await dbObj.database;
    return await database.query("users",where: "login_id=? AND password=? AND isdeleted=?",whereArgs: [loginId,password,"0"]);
  }

  Future<int> insertUser(String name,String login_id,String password,int role_id) async{
    final database = await dbObj.database;
    return await database.insert(
        "users",
          {
            "name" : name,
            "login_id" : login_id,
            "password" : password,
            "role_id" : role_id,
            "created_at" : DateTime.now().toString()
          }
        );
  }

  Future<void> updateUser(int id,String name,String loginId,String password,int role_id) async{
    final database = await dbObj.database;
    await database.update(
        "users",
        {
          "name" : name,
          "login_id" : loginId,
          "password" : password,
          "role_id" : role_id
        },
        where: "id=?",
        whereArgs: [id]
    );
  }

  Future<void> deleteUser(int id) async{
    final database = await dbObj.database;
    await database.update("users",{"isdeleted":1},where: "id=?",whereArgs: [id]);
  }
}
