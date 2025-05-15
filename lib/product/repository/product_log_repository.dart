import 'package:win_pos/core/database/db_helper.dart';

class ProductLogRepository {
  DbHelper dbObj = DbHelper();

  //get all adjust
  Future<List> getAll() async {
    final database = await dbObj.database;
    String sql = '''
      select product_log.date, products.name as product, product_log.quantity, product_log.note, users.name as user
      from product_log,products,users where product_log.product_id=products.id AND users.id=product_log.user_id 
      AND product_log.note="adjust" ORDER BY product_log.id DESC
      ''';
    return await database.rawQuery(sql);
  }

  //get all log
  Future<List> getAllLog({required int pid}) async {
    final database = await dbObj.database;
    String sql = '''
      select product_log.date, products.name as product, product_log.quantity, product_log.note, users.name as user
      from product_log,products,users where product_log.product_id=products.id AND users.id=product_log.user_id
      AND products.id=$pid ORDER BY product_log.id DESC
      ''';
    return await database.rawQuery(sql);
  }

  Future<List> getByDate(Map date) async {
    final database = await dbObj.database;
    String sql = '''
      select product_log.date, products.name as product, product_log.quantity, product_log.note, users.name as user
      from product_log,products,users where product_log.product_id=products.id AND users.id=product_log.user_id
      AND product_log.note="adjust" AND date>'${date['start']}' AND date<'${date['end']}' ORDER BY product_log.id DESC
    ''';
    return await database.rawQuery(sql);
  }

  Future<List> getAllLogByDate(Map date,int pid) async {
    final database = await dbObj.database;
    String sql = '''
      select product_log.date, products.name as product, product_log.quantity, product_log.note, users.name as user
      from product_log,products,users where product_log.product_id=products.id AND users.id=product_log.user_id
      AND products.id=$pid AND date>'${date['start']}' AND date<'${date['end']}' ORDER BY product_log.id DESC
    ''';
    return await database.rawQuery(sql);
  }
}
