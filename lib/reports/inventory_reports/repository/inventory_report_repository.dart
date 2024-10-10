import 'package:win_pos/core/database/db_helper.dart';

class InventoryReportRepository{
  DbHelper dbObj = DbHelper();
  String TABLE_NAME = "products";

  Future<List> getAll({int? catId}) async {
    final database = await dbObj.database;
    String sql = '''select * from products where isdeleted=0 ''';
    String endSql = "ORDER BY name;";
    if(catId!=null){
      sql+="AND category_id=$catId ";
    }
    return await database.rawQuery(
        "$sql$endSql"
    );
  }

  Future<List> getWithValue({int? catId}) async {
    final database = await dbObj.database;
    String sql = '''
      SELECT products.name,purchase_price.quantity,purchase_price.price,
      (purchase_price.quantity*purchase_price.price) as total 
      FROM products,purchase_price WHERE products.id=purchase_price.product_id 
    ''';
    String endSql = "ORDER BY products.name;";
    if(catId!=null){
      sql+="AND products.category_id=$catId ";
    }
    return await database.rawQuery(
        "$sql$endSql"
    );
  }
}