import 'package:win_pos/core/database/db_helper.dart';

class PurchaseDetailRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getPurchaseDetail(int phid) async {
    final database = await dbObj.database;
    return await database.rawQuery("""
        SELECT products.id,products.name,purchase_detail.quantity,purchase_detail.price 
        FROM products,purchase_detail WHERE products.id=purchase_detail.product_id 
        AND purchase_detail.purchase_id=$phid
        """);
  }
}
