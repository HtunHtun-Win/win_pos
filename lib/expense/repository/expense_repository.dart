import 'package:win_pos/core/database/db_helper.dart';
import 'package:win_pos/expense/model/expense_model.dart';

class ExpenseRepository{
  DbHelper dbObj = DbHelper();
  String TABLE_NAME = "income_expense";

  Future<List> getAll() async{
    final database = await dbObj.database;
    return await database.query(
      TABLE_NAME,
      where: "isdeleted=0",
      orderBy: "created_at desc",
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

  Future<int> updateDesc(String oldValue , String newValue) async{
    final database = await dbObj.database;
    return await database.update(
      TABLE_NAME,
      {
        "description" : newValue,
      },
      where: "description=?",
      whereArgs: [oldValue]
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

  Future<int> addExpense(ExpenseModel model) async{
    final database = await dbObj.database;
    return await database.insert(
        TABLE_NAME,
        {
          "amount" : model.amount,
          "description" : model.description,
          "note" : model.note,
          "flow_type_id" : model.type,
          "user_id" : model.userId,
          "created_at" : model.createdDate,
        }
    );
  }

  Future<int> updateExpense(ExpenseModel model) async{
    final database = await dbObj.database;
    return await database.update(
        TABLE_NAME,
        {
          "amount" : model.amount,
          "description" : model.description,
          "note" : model.note,
          "flow_type_id" : model.type,
          "user_id" : model.userId,
          "created_at" : model.createdDate,
        },
        where: 'id=?',
        whereArgs: [model.id]
    );
  }

  Future<void> deleteExpense(int id) async{
    final database = await dbObj.database;
    await database.delete(TABLE_NAME,where: "id=?",whereArgs: [id]);
  }
}