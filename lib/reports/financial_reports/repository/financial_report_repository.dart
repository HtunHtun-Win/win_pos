import 'package:win_pos/core/database/db_helper.dart';

class FinancialReportRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getBankPayment({int? paymentId, Map? date}) async {
    final database = await dbObj.database;
    String sql = """
      SELECT sales.id,sales.sale_no,customers.name as customer,users.name as user,sales.net_price,sales.discount,sales.total_price,payment_type.name as payment,sales.created_at 
      FROM sales,customers,users,payment_type WHERE sales.customer_id=customers.id AND sales.user_id=users.id AND sales.payment_type_id=payment_type.id AND payment_type.id!=1 """;
    String endSql = "ORDER BY sales.id DESC;";
    if (paymentId != null) {
      sql += "AND payment_type.id=$paymentId ";
    }
    if (date != null) {
      sql +=
      "AND sales.created_at>'${date['start']}' AND sales.created_at<'${date['end']}' ";
    }
    return await database.rawQuery(
        "$sql$endSql"
    );
  }

  Future<List> getProfitLose(Map date) async {
    final database = await dbObj.database;
    String sql = """
    SELECT 
    SUM(sales_detail.price * sales_detail.quantity) AS sale_total, 
    SUM(sales_detail.pprice * sales_detail.quantity) AS org_total,
    (SELECT SUM(sales.discount) FROM sales WHERE sales.created_at>'${date['start']}' AND sales.created_at<'${date['end']}') AS sale_discount,
    (SELECT SUM(purchase.discount) FROM purchase WHERE purchase.created_at>'${date['start']}' AND purchase.created_at<'${date['end']}') AS purchase_discount,
    (SELECT SUM(products.purchase_price * product_log.quantity) 
        FROM products 
        JOIN product_log ON products.id = product_log.product_id 
        WHERE product_log.note = 'lose' AND product_log.created_at>'${date['start']}' AND product_log.created_at<'${date['end']}') AS lose
        FROM sales_detail WHERE sales_detail.created_at>'${date['start']}' AND sales_detail.created_at<'${date['end']}';""";
    return await database.rawQuery(sql);
  }
}