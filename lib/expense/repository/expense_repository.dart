import 'package:jue_pos/core/database/db_helper.dart';

class ExpenseRepository{
  DbHelper dbObj = DbHelper();
  String TABLE_NAME = "income_expense";

  Future<List> getAll() async{
    final database = await dbObj.database;
    return await database.query(TABLE_NAME);
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
        "user_id" : userId
      }
    );
  }
}