import 'package:win_pos/core/database/db_helper.dart';

class SaleDetailRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getSaleDetail(int sid) async {
    final database = await dbObj.database;
    return await database.rawQuery("""
        SELECT products.name,sales_detail.quantity,sales_detail.price 
        FROM products,sales_detail WHERE products.id=sales_detail.product_id 
        AND sales_detail.sales_id=$sid
        """);
  }
}
