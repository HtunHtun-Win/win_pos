import 'package:jue_pos/core/database/db_helper.dart';

class CustomerRepository{
  DbHelper dbObj = DbHelper();
  String TABLE_NAME = "customers";

  Future<List> getAll() async{
    final database = await dbObj.database;
    return await database.query(TABLE_NAME,where: "isdeleted=0",orderBy: "name");
  }

  Future<List> getByName(String name) async{
    final database = await dbObj.database;
    var data = await database.query(TABLE_NAME,where: "name=? AND isdeleted=0",whereArgs: [name]);
    return data;
  }

  Future<int> insert(String name, String phone, String address) async{
    final database = await dbObj.database;
    return await database.insert(
        TABLE_NAME,
        {
          "name" : name,
          "phone" : phone,
          "address" : address,
          "created_at" : DateTime.now().toString()
        }
    );
  }

  Future<int> update(int id,String name, String phone, String address) async{
    final database = await dbObj.database;
    return await database.update(
        TABLE_NAME,
        {
          "name" : name,
          "phone" : phone,
          "address" : address,
          "created_at" : DateTime.now().toString()
        },
        where: "id=?",
        whereArgs: [id]
    );
  }

  Future<void> delete(int id) async{
    final database = await dbObj.database;
    await database.update(
        TABLE_NAME,
        {
          "isdeleted" : 1
        },
        where: "id=?",
        whereArgs: [id]
    );
  }
}