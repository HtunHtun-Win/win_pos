import 'package:jue_pos/core/database/db_helper.dart';

class UserRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getAll() async {
    final database = await dbObj.database;
    return await database.query("users");
  }
}
