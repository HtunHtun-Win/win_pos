import 'package:jue_pos/core/database/db_helper.dart';

class ProductLogRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getAll() async {
    final database = await dbObj.database;
    String sql = '''
      select product_log.date, products.name as product, product_log.quantity, product_log.note, users.name as user
      from product_log,products,users where product_log.product_id=products.id AND users.id=product_log.user_id
    ''';
    return await database.rawQuery(sql);
  }

  Future<List> getByDate(Map date) async {
    final database = await dbObj.database;
    String sql = '''
      select product_log.date, products.name as product, product_log.quantity, product_log.note, users.name as user
      from product_log,products,users where product_log.product_id=products.id AND users.id=product_log.user_id
      AND date>'${date['start']}' AND date<'${date['end']}'
    ''';
    return await database.rawQuery(sql);
  }
}
