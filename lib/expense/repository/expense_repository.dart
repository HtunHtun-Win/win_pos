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

  Future<List> getAllByDesc(String desc) async{
    final database = await dbObj.database;
    return await database.query(
      TABLE_NAME,
      where: 'isdeleted=? AND description=?',
      whereArgs: [0,desc],
      orderBy: "id desc",
    );
  }

  Future<List> getAllDesc() async{
    final database = await dbObj.database;
    return await database.query(
        TABLE_NAME,
        columns: ["description"],
        groupBy: "description"
    );
  }

  Future<List> getDescByKeyword(String keyword) async{
    final database = await dbObj.database;
    keyword = keyword.length>=1 ? keyword : "-1";
    return await database.query(
        TABLE_NAME,
        columns: ["description"],
        where: "description like '%$keyword%'",
        groupBy: "description"
    );
  }

  Future<List> getAllByFilter(String startDate,String endDate,String desc) async{
    String query = "isdeleted=0 AND created_at>? AND created_at<?";
    List args = [startDate,endDate];
    if(desc!="all"){
      query+=" AND description=?";
      args.add(desc);
    }
    final database = await dbObj.database;
    return await database.query(
      TABLE_NAME,
      where: query,
      whereArgs: args,
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