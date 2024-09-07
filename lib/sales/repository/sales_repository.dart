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
    String invNo = await getInvNo();
    int saleId = await database.insert("sales", {
      "sale_no": invNo,
      "customer_id": sale.customer_id,
      "user_id": sale.user_id,
      "net_price": sale.net_price,
      "discount": sale.discount,
      "total_price": sale.total_price,
      "payment_type_id": sale.payment_type_id,
    });
    for (var item in cart) {
      int tempQty = item.quantity;
      while(tempQty>0){
        var pprice = await getPprice(item.product.id!);
        if(pprice['quantity']>=tempQty){
          addSaleDetail(saleId, item, pprice['price']);
          updatePprice(item.product.id!, -item.quantity);
          tempQty = 0;
        }else{
          addSaleDetail(saleId, item, pprice['price']);
          updatePprice(item.product.id!, -item.quantity);
          tempQty -= pprice['quantity'] as int;
        }
      }
      updateProductQty(item.product.id!, -item.quantity);
      addProductLog(item.product.id!, -item.quantity, "sales", 1);
    }
    return saleId;
  }

  Future<String> getInvNo() async{
    final database = await dbObj.database;
    String invNo = "";
    var datas = await database.query("gen_id",where: "id=?",whereArgs: [1]);
    var data = datas[0] as Map<String,dynamic>;
    int no = data['no'];
    int getLen = no+1;
    for(var digit = getLen.toString().length; digit < data['digit']; digit++){
      invNo += "0";
    }
    String fullInv = "${data['prefix']}${invNo}${data['no']+1}";
    updateInvNo();
    return fullInv;
  }

  void updateInvNo() async{
    final database = await dbObj.database;
    await database.rawUpdate("UPDATE gen_id SET no=no+1 WHERE id=1");
  }

  void addSaleDetail(int saleId, CartModel item, int pprice) async {
    final database = await dbObj.database;
    await database.insert(
      "sales_detail",
      {
        "sales_id": saleId,
        "product_id": item.product.id,
        "quantity": item.quantity,
        "price": item.sprice,
        "pprice": pprice,
      },
    );
  }

  Future<Map<String,dynamic>> getPprice(int pid) async{
    final database = await dbObj.database;
    var datas = await database.rawQuery(
        "SELECT quantity, price FROM purchase_price WHERE product_id=${pid} AND quantity!=0 ORDER BY id LIMIT 1"
    );
    return datas[0];
  }

  void updatePprice(int pid,int qty) async{
    final database = await dbObj.database;
    await database.rawQuery(
      "UPDATE purchase_price SET quantity=quantity+${qty} WHERE id=(SELECT id FROM purchase_price where product_id=${pid} ORDER BY id ASC LIMIT 1)"
    );
  }

  void updateProductQty(int id, int qty) async {
    final database = await dbObj.database;
    await database.rawUpdate(
        'update products set quantity=quantity+? where id=?', [qty, id]);
  }

  void updatePurchaseQty(int pid,int qty) async{
    final database = await dbObj.database;
    await database.rawUpdate(
        'UPDATE purchase_price SET quantity=quantity+? WHERE product_id=? AND quantity!=0 ORDER BY id LIMIT 1',
        [qty, pid],
    );
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
