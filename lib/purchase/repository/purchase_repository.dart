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
      AND products.isdeleted=0;
    ''';
    return await database.rawQuery(sql);
  }

  Future<List> getAllVouchers() async {
    final database = await dbObj.database;
    return await database.rawQuery(
        """
      SELECT purchase.id,purchase.purchase_no,suppliers.name as customer,users.name as user,purchase.net_price,purchase.discount,purchase.total_price,payment_type.name as payment,purchase.created_at 
      FROM purchase,suppliers,users,payment_type WHERE purchase.isdeleted=0 AND purchase.supplier_id=suppliers.id AND purchase.user_id=users.id AND purchase.payment_type_id=payment_type.id ORDER BY purchase.id DESC;
      """
    );
  }

  Future<List> getVouchersDate(Map date) async {
    final database = await dbObj.database;
    return await database.rawQuery("""
      SELECT purchase.id,purchase.purchase_no,suppliers.name as customer,users.name as user,purchase.net_price,purchase.discount,purchase.total_price,payment_type.name as payment,purchase.created_at 
      FROM purchase,suppliers,users,payment_type WHERE purchase.isdeleted=0 AND purchase.supplier_id=suppliers.id AND purchase.user_id=users.id AND purchase.payment_type_id=payment_type.id
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
      "created_at": DateTime.now().toString(),
      "payment_type_id" : map["payment_type_id"],
    });
    for (var item in cart) {
      addPurchaseDetail(purchaseId, item);
      updateProduct(item.product.id!, item.quantity, item.pprice!);
      addPurchasePrice(item.product.id!, item.quantity, item.pprice!);
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
        "price": item.pprice,
        "created_at": DateTime.now().toString()
      },
    );
  }

  void deletePurchaseVoucher(int vid) async {
    final database = await dbObj.database;
    await database.rawUpdate("UPDATE purchase SET isdeleted=1 WHERE id=$vid");
  }

  void deletePurchaseDetail(int vid) async {
    final database = await dbObj.database;
    await database.delete(
      "purchase_detail",where: "purchase_id=?",whereArgs: [vid],
    );
  }

  Future<void> addPurchasePrice(int productId, int quantity, int price) async {
    final database = await dbObj.database;
    await database.insert(
      "purchase_price",
      {"product_id": productId, "quantity": quantity, "price": price},
    );
  }

  Future<Map<String, dynamic>> getPprice(int pid) async {
    final database = await dbObj.database;
    var datas = await database.rawQuery(
        "SELECT quantity, price FROM purchase_price WHERE product_id=$pid AND quantity!=0 ORDER BY id LIMIT 1");
    return datas[0];
  }

  void updatePprice(int pid, int qty) async {
    final database = await dbObj.database;
    await database.rawQuery(
        "UPDATE purchase_price SET quantity=quantity-$qty WHERE id=(SELECT id FROM purchase_price where product_id=$pid ORDER BY id DESC LIMIT 1)"
    );
  }

  void removePprice(int pid, int qty) async {
    int tempQty = qty;
    while (tempQty > 0) {
      var pprice = await getPprice(pid);
      if (pprice['quantity'] >= tempQty) {
        updatePprice(pid, -tempQty);
        tempQty = 0;
      } else {
        updatePprice(pid, -pprice['quantity']);
        tempQty -= pprice['quantity'] as int;
      }
    }
  }

  void updateProduct(int id, int qty, int price) async {
    final database = await dbObj.database;
    await database.rawUpdate(
        'update products set quantity=quantity+?,purchase_price=? where id=?', [qty, price, id]);
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
