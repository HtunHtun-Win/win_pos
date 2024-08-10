import 'package:jue_pos/core/database/db_helper.dart';

class CategoryRepository{
  DbHelper dbObj = DbHelper();

  Future<List> getAll() async{
    final database = await dbObj.database;
    return await database.query("categories",where: "isdeleted=0",orderBy: "name");
  }

  Future<int> insertCategory(String name,String description) async{
    final database = await dbObj.database;
    return await database.insert("categories", {
      "name" : name,
      "description" : description,
      "created_at" : DateTime.now().toString(),
      "updated_at" : DateTime.now().toString(),
    });
  }

  Future<void> updateCategory(int id,String name,String description) async{
    final database = await dbObj.database;
    await database.update(
        "categories",
        {
          "name":name,
          "description":description,
          "updated_at":DateTime.now().toString()
        },
        where: "id=?",
        whereArgs: [id]);
  }

  Future<void> deleteCategory(int id) async{
    final database = await dbObj.database;
    await database.update("categories",{"isdeleted":1},where: "id=?",whereArgs: [id]);
  }

  Future<List> getByName(String name) async{
    final database = await dbObj.database;
    return database.query("categories",where: "name=? AND isdeleted=0",whereArgs: [name]);
  }
}