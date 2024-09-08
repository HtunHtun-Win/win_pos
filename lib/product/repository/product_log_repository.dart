import 'package:win_pos/core/database/db_helper.dart';
import 'dart:developer' as dev;

class ProductLogRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getAll() async {
    final database = await dbObj.database;
    String sql = '''
      select product_log.date, products.name as product, product_log.quantity, product_log.note, users.name as user
      from product_log,products,users where product_log.product_id=products.id AND users.id=product_log.user_id 
      ORDER BY product_log.id DESC
    ''';
    return await database.rawQuery(sql);
  }

  Future<List> getByDate(Map date) async {
    final database = await dbObj.database;
    String sql = '''
      select product_log.date, products.name as product, product_log.quantity, product_log.note, users.name as user
      from product_log,products,users where product_log.product_id=products.id AND users.id=product_log.user_id
      AND date>'${date['start']}' AND date<'${date['end']}' ORDER BY product_log.id DESC
    ''';
    return await database.rawQuery(sql);
  }
}
