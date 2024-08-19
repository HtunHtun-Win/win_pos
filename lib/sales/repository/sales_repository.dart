import 'package:win_pos/core/database/db_helper.dart';

class SalesRepository{
  DbHelper dbObj = DbHelper();

  Future<List> getByFilter(String input) async{
    final database = await dbObj.database;
    String sql = '''
      select products.id, products.code, products.name, products.description, products.quantity, 
      products.category_id,categories.name as category_name,products.purchase_price,products.sale_price
      from products inner join categories on categories.id=products.category_id 
      where products.name like '%$input%' OR products.code like '%$input%' AND products.isdeleted=0;
    ''';
    return await database.rawQuery(sql);
  }

  Future<List> getById(int id) async{
    final database = await dbObj.database;
    String sql = '''
      select products.id, products.code, products.name, products.description, products.quantity, 
      products.category_id,categories.name as category_name,products.purchase_price,products.sale_price
      from products inner join categories on categories.id=products.category_id 
      where products.id=$id AND products.isdeleted=0;
    ''';
    return await database.rawQuery(sql);
  }
}