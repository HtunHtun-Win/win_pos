import 'package:win_pos/core/database/db_helper.dart';

class SaleDetailRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getSaleDetail(int sid) async {
    final database = await dbObj.database;
    return await database.query(
      "sales_detail",
      where: "sales_id=?",
      whereArgs: [sid],
    );
  }

  Future<List> getProductById(int id) async {
    final database = await dbObj.database;
    return await database.query(
      "products",
      columns: ["name"],
      where: "id=?",
      whereArgs: [id],
    );
  }
}
