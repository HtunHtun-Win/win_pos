import 'package:win_pos/core/database/db_helper.dart';

class SaleDetailRepository {
  DbHelper dbObj = DbHelper();

  //to show sale detail in voucher
  Future<List> getSaleDetail(int sid) async {
    final database = await dbObj.database;
    return await database.rawQuery("""
        SELECT products.id,products.name,SUM(sales_detail.quantity) as quantity,sales_detail.price ,sales_detail.pprice 
        FROM products,sales_detail WHERE products.id=sales_detail.product_id 
        AND sales_detail.sales_id=$sid GROUP BY (products.id);
        """);
  }

  //to delete voucher
  Future<List> getSaleDetailToDelete(int sid) async {
    final database = await dbObj.database;
    return await database.rawQuery("""
        SELECT products.id,products.name,sales_detail.quantity,sales_detail.price ,sales_detail.pprice 
        FROM products,sales_detail WHERE products.id=sales_detail.product_id 
        AND sales_detail.sales_id=$sid;
        """);
  }
}
