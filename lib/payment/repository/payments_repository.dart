import 'package:win_pos/core/database/db_helper.dart';

class PaymentsRepository{
  DbHelper dbObj = DbHelper();
  var TABLE_NAME = "payment_type";

  Future<List> getAll() async{
    final database = await dbObj.database;
    return await database.query(TABLE_NAME,where: "isdeleted=0",orderBy: "name");
  }

  Future<int> insertPayment(String name,String description) async{
    final database = await dbObj.database;
    return await database.insert(TABLE_NAME, {
      "name" : name,
      "description" : description,
      "created_at" : DateTime.now().toString(),
    });
  }

  Future<void> updatePayment(int id,String name,String description) async{
    final database = await dbObj.database;
    await database.update(
        TABLE_NAME,
        {
          "name":name,
          "description":description,
        },
        where: "id=?",
        whereArgs: [id]);
  }

  Future<void> deletePayment(int id) async{
    final database = await dbObj.database;
    await database.update(TABLE_NAME,{"isdeleted":1},where: "id=?",whereArgs: [id]);
  }

  Future<List> getByName(String name) async{
    final database = await dbObj.database;
    return database.query(TABLE_NAME,where: "name=? AND isdeleted=0",whereArgs: [name]);
  }
}