import 'package:win_pos/core/database/db_helper.dart';

class SalesReportRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getAllVouchers({int? customerId,Map? date}) async {
    final database = await dbObj.database;
    String sql = """
      SELECT sales.id,sales.sale_no,customers.name as customer,users.name as user,sales.net_price,sales.discount,sales.total_price,payment_type.name as payment,sales.created_at 
      FROM sales,customers,users,payment_type WHERE sales.customer_id=customers.id AND sales.user_id=users.id AND sales.payment_type_id=payment_type.id """;
    String endSql = "ORDER BY sales.id DESC;";
    if(customerId!=null){
      sql+="AND customers.id=$customerId ";
    }
    if(date!=null){
      sql+="AND sales.created_at>'${date['start']}' AND sales.created_at<'${date['end']}' ";
    }
    return await database.rawQuery(
        "$sql$endSql"
    );
  }

  Future<List> getSaleItems({int? catId,Map? date}) async {
    final database = await dbObj.database;
    String sql = """
    SELECT products.name,SUM(sales_detail.quantity) as quantity,SUM(sales_detail.quantity*sales_detail.price) as price
    FROM products,sales_detail WHERE products.id=sales_detail.product_id """;
    String endSql = "GROUP BY products.name ORDER BY products.name;";
    if(catId!=null){
      sql+="AND products.category_id=$catId ";
    }
    if(date!=null){
      sql+="AND sales_detail.created_at>'${date['start']}' AND sales_detail.created_at<'${date['end']}' ";
    }
    return await database.rawQuery(
        "$sql$endSql"
    );
  }
}
