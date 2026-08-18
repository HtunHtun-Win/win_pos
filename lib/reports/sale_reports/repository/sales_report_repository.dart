import 'package:win_pos/core/database/db_helper.dart';

class SalesReportRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getAllVouchers({int? customerId, Map? date}) async {
    final database = await dbObj.database;
    String sql = """
      SELECT sales.id,sales.sale_no,customers.name as customer,users.name as user,sales.net_price,sales.discount,sales.total_price,payment_type.name as payment,sales.created_at 
      FROM sales,customers,users,payment_type WHERE sales.isdeleted=0 AND sales.customer_id=customers.id AND sales.user_id=users.id AND sales.payment_type_id=payment_type.id """;
    String endSql = "ORDER BY sales.id DESC;";
    if (customerId != null) {
      sql += "AND customers.id=$customerId ";
    }
    if (date != null) {
      sql +=
          "AND sales.created_at>'${date['start']}' AND sales.created_at<'${date['end']}' ";
    }
    return await database.rawQuery("$sql$endSql");
  }

  Future<List> getVipCustomer({Map? date}) async {
    final database = await dbObj.database;
    String sql = """
      SELECT customers.name as customer,SUM(sales.total_price) as total
      FROM sales,customers WHERE sales.isdeleted=0 AND sales.customer_id=customers.id """;
    String endSql = "GROUP BY customers.name ORDER BY total DESC LIMIT 50;";
    if (date != null) {
      sql +=
          "AND sales.created_at>'${date['start']}' AND sales.created_at<'${date['end']}' ";
    }
    return await database.rawQuery("$sql$endSql");
  }

  Future<List> getSaleItems({int? catId, Map? date}) async {
    final database = await dbObj.database;
    String sql = """
    SELECT products.name,SUM(sales_detail.quantity) as quantity,SUM(sales_detail.quantity*sales_detail.price) as price
    FROM products,sales_detail WHERE products.id=sales_detail.product_id """;
    String endSql = "GROUP BY products.name ORDER BY products.name;";
    if (catId != null) {
      sql += "AND products.category_id=$catId ";
    }
    if (date != null) {
      sql +=
          "AND sales_detail.created_at>'${date['start']}' AND sales_detail.created_at<'${date['end']}' ";
    }
    return await database.rawQuery("$sql$endSql");
  }

  Future<List> getMostSaleItems({int? catId, Map? date}) async {
    final database = await dbObj.database;
    String sql = """
    SELECT products.name,SUM(sales_detail.quantity) as quantity,SUM(sales_detail.quantity*sales_detail.price) as price
    FROM products,sales_detail WHERE products.id=sales_detail.product_id """;
    String endSql = "GROUP BY products.name ORDER BY quantity DESC LIMIT 20;";
    if (catId != null) {
      sql += "AND products.category_id=$catId ";
    }
    if (date != null) {
      sql +=
          "AND sales_detail.created_at>'${date['start']}' AND sales_detail.created_at<'${date['end']}' ";
    }
    return await database.rawQuery("$sql$endSql");
  }

  //sales item report by month
  Future<List<Map<String, dynamic>>> getMonthlySalesItem({
    required int year,
    required int productId,
  }) async {
    final database = await dbObj.database;

    final result = await database.rawQuery(
      '''
    SELECT
      CAST(strftime('%m', sales.created_at) AS INTEGER) AS month,
      COALESCE(
        SUM(sales_detail.quantity * sales_detail.price),
        0
      ) AS total
    FROM sales
    INNER JOIN sales_detail
      ON sales.id = sales_detail.sales_id
    WHERE sales.isdeleted = 0
      AND sales_detail.product_id = ?
      AND strftime('%Y', sales.created_at) = ?
    GROUP BY strftime('%m', sales.created_at)
    ORDER BY month ASC
    ''',
      [
        productId,
        year.toString(),
      ],
    );

    return List<Map<String, dynamic>>.from(result);
  }

  //sale report by month
  Future<List<Map<String, dynamic>>> getMonthlySales({
    int? year,
  }) async {
    final database = await dbObj.database;

    final selectedYear = year ?? DateTime.now().year;

    String sql = '''
    SELECT
      CAST(strftime('%m', sales.created_at) AS INTEGER) AS month,
      COALESCE(SUM(sales.total_price), 0) AS total
    FROM sales
    WHERE sales.isdeleted = 0
      AND strftime('%Y', sales.created_at) = ?
  ''';

    final List<dynamic> args = [
      selectedYear.toString(),
    ];

    sql += '''
    GROUP BY strftime('%m', sales.created_at)
    ORDER BY month ASC
  ''';

    final result = await database.rawQuery(
      sql,
      args,
    );

    // Always return January -> December
    final List<Map<String, dynamic>> months = List.generate(
      12,
      (index) => {
        'month': index + 1,
        'total': 0,
      },
    );

    for (final row in result) {
      final month = row['month'] as int;

      months[month - 1] = {
        'month': month,
        'total': row['total'],
      };
    }

    return months;
  }

  //sale report by yearly
  Future<List<Map<String, dynamic>>> getYearlySales() async {
    final database = await dbObj.database;

    final currentYear = DateTime.now().year;

    final startYear = currentYear - 5;

    String sql = '''
    SELECT
      CAST(strftime('%Y', sales.created_at) AS INTEGER) AS year,
      COALESCE(SUM(sales.total_price), 0) AS total
    FROM sales
    WHERE sales.isdeleted = 0
      AND CAST(strftime('%Y', sales.created_at) AS INTEGER)
          BETWEEN ? AND ?
  ''';

    final List<dynamic> args = [
      startYear,
      currentYear,
    ];

    sql += '''
    GROUP BY strftime('%Y', sales.created_at)
    ORDER BY year ASC
  ''';

    final result = await database.rawQuery(
      sql,
      args,
    );

    // Always return 6 years.
    final List<Map<String, dynamic>> years = List.generate(
      6,
      (index) {
        return {
          'year': startYear + index,
          'total': 0,
        };
      },
    );

    for (final row in result) {
      final year = row['year'] as int;

      final index = year - startYear;

      if (index >= 0 && index < 6) {
        years[index] = {
          'year': year,
          'total': row['total'],
        };
      }
    }

    return years;
  }
}
