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

  Future<List> getLowQtyStock({int? catId}) async {
    final database = await dbObj.database;
    String sql = '''select * from products where isdeleted=0 AND quantity<=10 ''';
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
      AND purchase_price.quantity!=0 
    ''';
    String endSql = "ORDER BY products.name;";
    if(catId!=null){
      sql+="AND products.category_id=$catId ";
    }
    return await database.rawQuery(
        "$sql$endSql"
    );
  }

  Future<List> getSalePriceLog({int? pid,Map? date}) async {
      final database = await dbObj.database;
      String sql = """
        SELECT products.name as name,sale_price_log.old_price as old_price,sale_price_log.new_price as new_price,sale_price_log.created_at as date
        FROM products,sale_price_log WHERE products.id==sale_price_log.product_id """;
      String endSql = "ORDER BY sale_price_log.id DESC;";
      if(pid!=null){
        sql+="AND sale_price_log.product_id=$pid ";
      }
      if(date!=null){
        sql+="AND sale_price_log.created_at>'${date['start']}' AND sale_price_log.created_at<'${date['end']}' ";
      }
      return await database.rawQuery(
          "$sql$endSql"
      );
  }
}