import 'package:win_pos/core/database/db_helper.dart';

class ProductRepository{

  DbHelper dbObj = DbHelper();
  String TABLE_NAME = "products";
  String LOG_TABLE_NAME = "product_log";


  Future<List> getAll() async{
    final database = await dbObj.database;
    String sql = '''
      select products.id, products.code, products.name, products.description, products.quantity, 
      products.category_id,categories.name as category_name,products.purchase_price,products.sale_price
      from products inner join categories on categories.id=products.category_id 
      where products.isdeleted=0;
    ''';
    return await database.rawQuery(sql);
  }

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

  Future<List> getByCode(String code) async{
    final database = await dbObj.database;
    return await database.query(TABLE_NAME,where:"code=?",whereArgs: [code]);
  }

  Future<int> addProduct(String code,String name,String description,int quantity,int category_id,int purchase_price,int sale_price) async{
    final database = await dbObj.database;
    var num = await database.insert(
      TABLE_NAME,
      {
        "code" : code,
        "name" : name,
        "description" : description,
        "quantity" : quantity,
        "category_id" : category_id,
        "purchase_price" : purchase_price,
        "sale_price" : sale_price,
      }
    );
    return num;
  }

  Future<int> updateProduct(int id, String code, String name,String description,int category_id) async{
    final database = await dbObj.database;
    var num = await database.update(
        TABLE_NAME,
        {
          "code" : code,
          "name" : name,
          "description" : description,
          "category_id" : category_id,
        },
        where: "id=?",
        whereArgs: [id]
    );
    return num;
  }

  Future<int> updateProductQty(int id, int qty) async{
    final database = await dbObj.database;
    var num = await database.rawUpdate(
        'update $TABLE_NAME set quantity=quantity+? where id=?',
        [qty,id]
    );
    return num;
  }

  Future<void> deleteProduct(int id) async{
    final database = await dbObj.database;
    await database.update(
      TABLE_NAME,
      {
        "isdeleted":1
      },
        where: "id=?",
        whereArgs: [id]
    );
  }

  Future<void> addProductLog(int productId,int quantity,String note,int userId) async{
    final database = await dbObj.database;
    await database.insert(
        LOG_TABLE_NAME,
        {
          "date" : DateTime.now().toString(),
          "product_id" : productId,
          "quantity" : quantity,
          "note" : note,
          "user_id" : userId
        }
    );
  }

  Future<void> addPurchasePrice(int productId,int quantity,int price) async{
    final database = await dbObj.database;
    await database.insert(
        "purchase_price",
        {
          "product_id" : productId,
          "quantity" : quantity,
          "price" : price
        }
    );
  }

  Future<void> updatePurchasePriceQty(int productId,int quantity) async{
    final database = await dbObj.database;
    await database.rawUpdate(
        "UPDATE purchase_price set quantity=quantity+? where id=(select id from purchase_price where product_id=? order by id desc limit 1)",
      [quantity,productId]
    );
  }

}