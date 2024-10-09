import 'package:win_pos/core/database/db_helper.dart';

class PurchaseReportRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getAllVouchers({int? supplierId,Map? date}) async {
    final database = await dbObj.database;
    String sql = """
      SELECT purchase.id,purchase.purchase_no,suppliers.name as customer,users.name as user,purchase.net_price,purchase.discount,purchase.total_price,purchase.created_at 
      FROM purchase,suppliers,users WHERE purchase.supplier_id=suppliers.id AND purchase.user_id=users.id """;
    String endSql = "ORDER BY purchase.id DESC;";
    if(supplierId!=null){
      sql+="AND suppliers.id=$supplierId ";
    }
    if(date!=null){
      sql+="AND purchase.created_at>'${date['start']}' AND purchase.created_at<'${date['end']}' ";
    }
    return await database.rawQuery(
        "$sql$endSql"
    );
  }

  Future<List> getSaleItems({int? catId,Map? date}) async {
    final database = await dbObj.database;
    String sql = """
    SELECT products.name,SUM(purchase_detail.quantity) as quantity,SUM(purchase_detail.quantity*purchase_detail.price) as price
    FROM products,purchase_detail WHERE products.id=purchase_detail.product_id """;
    String endSql = "GROUP BY products.name ORDER BY products.name;";
    if(catId!=null){
      sql+="AND products.category_id=$catId ";
    }
    if(date!=null){
      sql+="AND purchase_detail.created_at>'${date['start']}' AND purchase_detail.created_at<'${date['end']}' ";
    }
    return await database.rawQuery(
        "$sql$endSql"
    );
  }
}
