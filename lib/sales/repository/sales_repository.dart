import 'package:win_pos/core/database/db_helper.dart';
import 'package:win_pos/sales/models/cart_model.dart';
import 'package:win_pos/sales/models/sale_model.dart';

class SalesRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getByFilter(String input) async {
    final database = await dbObj.database;
    String sql = '''
      select products.id, products.code, products.name, products.description, products.quantity, 
      products.category_id,categories.name as category_name,products.purchase_price,products.sale_price
      from products inner join categories on categories.id=products.category_id 
      where (products.name like '%$input%' OR products.code like '%$input%') AND products.isdeleted=0;
    ''';
    return await database.rawQuery(sql);
  }

  Future<List> getAllVouchers() async {
    final database = await dbObj.database;
    return await database.query("sales");
  }

  Future<List> getCustomer() async {
    final database = await dbObj.database;
    return await database.query("customers");
  }

  Future<List> getById(int id) async {
    final database = await dbObj.database;
    String sql = '''
      select products.id, products.code, products.name, products.description, products.quantity, 
      products.category_id,categories.name as category_name,products.purchase_price,products.sale_price
      from products inner join categories on categories.id=products.category_id 
      where products.id=$id AND products.isdeleted=0;
    ''';
    return await database.rawQuery(sql);
  }

  Future<int> addSale(SaleModel sale, List<CartModel> cart) async {
    final database = await dbObj.database;
    int saleId = await database.insert("sales", {
      "sale_no": sale.sale_no,
      "customer_id": sale.customer_id,
      "user_id": sale.user_id,
      "net_price": sale.net_price,
      "discount": sale.discount,
      "total_price": sale.total_price,
      "payment_type_id": sale.payment_type_id,
    });
    for (var item in cart) {
      addSaleDetail(saleId, item);
      updateProductQty(item.product.id!, -item.quantity);
      addProductLog(item.product.id!, -item.quantity, "sales", 1);
    }
    return saleId;
  }

  void addSaleDetail(int saleId, CartModel item) async {
    final database = await dbObj.database;
    await database.insert(
      "sales_detail",
      {
        "sale_id": saleId,
        "product_id": item.product.id,
        "quantity": -item.quantity,
      },
    );
  }

  void updateProductQty(int id, int qty) async {
    final database = await dbObj.database;
    await database.rawUpdate(
        'update products set quantity=quantity+? where id=?', [qty, id]);
  }

  Future<void> addProductLog(
      int productId, int quantity, String note, int userId) async {
    final database = await dbObj.database;
    await database.insert("product_log", {
      "date": DateTime.now().toString(),
      "product_id": productId,
      "quantity": quantity,
      "note": note,
      "user_id": userId
    });
  }
}
