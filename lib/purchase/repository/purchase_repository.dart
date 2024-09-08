import 'package:win_pos/core/database/db_helper.dart';
import 'package:win_pos/sales/models/cart_model.dart';

class PurchaseRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getByFilter(String input) async {
    final database = await dbObj.database;
    String sql = '''
      select products.id, products.code, products.name, products.description, products.quantity, 
      products.category_id,categories.name as category_name,products.purchase_price,products.sale_price
      from products inner join categories on categories.id=products.category_id 
      where (products.name like '%$input%' OR products.code like '%$input%') 
      AND products.isdeleted=0 AND products.quantity!=0;
    ''';
    return await database.rawQuery(sql);
  }

  Future<List> getAllVouchers() async {
    final database = await dbObj.database;
    return await database.rawQuery("""
      SELECT purchase.id,purchase.purchase_no,suppliers.name as customer,users.name as user,purchase.net_price,purchase.discount,purchase.total_price,purchase.created_at 
      FROM purchase,suppliers,users WHERE purchase.supplier_id=suppliers.id AND purchase.user_id=users.id ORDER BY purchase.id DESC;
      """);
  }

  Future<List> getVouchersDate(Map date) async {
    final database = await dbObj.database;
    return await database.rawQuery("""
      SELECT purchase.id,purchase.purchase_no,suppliers.name as customer,users.name as user,purchase.net_price,purchase.discount,purchase.total_price,purchase.created_at 
      FROM purchase,suppliers,users WHERE purchase.supplier_id=suppliers.id AND purchase.user_id=users.id
      AND purchase.created_at>'${date['start']}' AND purchase.created_at<'${date['end']}' ORDER BY purchase.id DESC;
      """);
  }

  Future<int> addPurchase(Map map, List<CartModel> cart) async {
    final database = await dbObj.database;
    String invNo = await getInvNo();
    int purchaseId = await database.insert("purchase", {
      "purchase_no": invNo,
      "supplier_id": map["supplier_id"],
      "user_id": map["user_id"],
      "net_price": map["net_price"],
      "discount": map["discount"],
      "total_price": map["total_price"],
      "created_at": DateTime.now().toString()
    });
    for (var item in cart) {
      addPurchaseDetail(purchaseId, item);
      updateProductQty(item.product.id!, item.quantity);
      addProductLog(item.product.id!, item.quantity, "purchase", 1);
    }
    return purchaseId;
  }

  Future<String> getInvNo() async {
    final database = await dbObj.database;
    String invNo = "";
    var datas = await database.query("gen_id", where: "id=?", whereArgs: [2]);
    var data = datas[0] as Map<String, dynamic>;
    int no = data['no'];
    int getLen = no + 1;
    for (var digit = getLen.toString().length; digit < data['digit']; digit++) {
      invNo += "0";
    }
    String fullInv = "${data['prefix']}$invNo${data['no'] + 1}";
    updateInvNo();
    return fullInv;
  }

  void updateInvNo() async {
    final database = await dbObj.database;
    await database.rawUpdate("UPDATE gen_id SET no=no+1 WHERE id=2");
  }

  void addPurchaseDetail(int saleId, CartModel item) async {
    final database = await dbObj.database;
    await database.insert(
      "purchase_detail",
      {
        "purchase_id": saleId,
        "product_id": item.product.id,
        "quantity": item.quantity,
        "price": item.sprice,
        "created_at": DateTime.now().toString()
      },
    );
  }

  Future<void> addPurchasePrice(int productId, int quantity, int price) async {
    final database = await dbObj.database;
    await database.insert(
      "purchase_price",
      {"product_id": productId, "quantity": quantity, "price": price},
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
