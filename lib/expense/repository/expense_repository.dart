import 'package:win_pos/core/database/db_helper.dart';

class ExpenseRepository{
  DbHelper dbObj = DbHelper();
  String TABLE_NAME = "income_expense";

  Future<List> getAll() async{
    final database = await dbObj.database;
    return await database.query(
      TABLE_NAME,
      where: "isdeleted=0",
      orderBy: "id desc",
      );
  }

  Future<List> getAllByDate(String startDate,String endDate) async{
    final database = await dbObj.database;
    return await database.query(
      TABLE_NAME,
      where: "isdeleted=0 AND created_at>? AND created_at<?",
      whereArgs: [startDate,endDate],
      orderBy: "id desc",
    );
  }

  Future<int> addExpense(int amount, String description, String note, int type, int userId) async{
    final database = await dbObj.database;
    return await database.insert(
      TABLE_NAME,
      {
        "amount" : amount,
        "description" : description,
        "note" : note,
        "flow_type_id" : type,
        "user_id" : userId,
        "created_at" : DateTime.now().toString(),
      }
    );
  }

  Future<int> updateExpense(int id, int amount, String description, String note, int type, int userId) async{
    final database = await dbObj.database;
    return await database.update(
      TABLE_NAME,
      {
        "amount" : amount,
        "description" : description,
        "note" : note,
        "flow_type_id" : type,
        "user_id" : userId
      },
      where: 'id=?',
      whereArgs: [id]
    );
  }

  Future<void> deleteExpense(int id) async{
    final database = await dbObj.database;
    await database.delete(TABLE_NAME,where: "id=?",whereArgs: [id]);
  }
}