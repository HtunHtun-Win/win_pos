import 'package:win_pos/core/database/db_helper.dart';

class PurchaseReportRepository {
  DbHelper dbObj = DbHelper();

  Future<List> getAllVouchers({int? supplierId, Map? date}) async {
    final database = await dbObj.database;
    String sql = """
      SELECT purchase.id,purchase.purchase_no,suppliers.name as customer,users.name as user,purchase.net_price,purchase.discount,purchase.total_price,payment_type.name as payment,purchase.created_at 
      FROM purchase,suppliers,users,payment_type WHERE purchase.isdeleted=0 AND purchase.supplier_id=suppliers.id AND purchase.user_id=users.id AND purchase.payment_type_id=payment_type.id
      """;
    String endSql = "ORDER BY purchase.id DESC;";
    if (supplierId != null) {
      sql += "AND suppliers.id=$supplierId ";
    }
    if (date != null) {
      sql +=
          "AND purchase.created_at>'${date['start']}' AND purchase.created_at<'${date['end']}' ";
    }
    return await database.rawQuery("$sql$endSql");
  }

  //for monthly
  Future<List<Map<String, dynamic>>> getMonthlyPurchase({
    required int year,
  }) async {
    final database = await dbObj.database;

    String sql = '''
    SELECT
      CAST(strftime('%m', purchase.created_at) AS INTEGER) AS month,
      COALESCE(SUM(purchase.total_price), 0) AS total
    FROM purchase
    WHERE purchase.isdeleted = 0
      AND CAST(strftime('%Y', purchase.created_at) AS INTEGER) = ?
  ''';

    final List<dynamic> args = [year];

    sql += '''
    GROUP BY strftime('%m', purchase.created_at)
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
      final month = _toInt(row['month']);

      if (month >= 1 && month <= 12) {
        months[month - 1] = {
          'month': month,
          'total': row['total'],
        };
      }
    }
    return months;
  }

  //for yearly
  Future<List<Map<String, dynamic>>> getYearlyPurchase() async {
    final database = await dbObj.database;

    final currentYear = DateTime.now().year;
    final startYear = currentYear - 5;

    String sql = '''
    SELECT
      CAST(strftime('%Y', purchase.created_at) AS INTEGER) AS year,
      COALESCE(SUM(purchase.total_price), 0) AS total
    FROM purchase
    WHERE purchase.isdeleted = 0
      AND CAST(strftime('%Y', purchase.created_at) AS INTEGER)
          BETWEEN ? AND ?
  ''';

    final List<dynamic> args = [
      startYear,
      currentYear,
    ];

    sql += '''
    GROUP BY strftime('%Y', purchase.created_at)
    ORDER BY year ASC
  ''';

    final result = await database.rawQuery(
      sql,
      args,
    );

    // Always return 6 years
    final List<Map<String, dynamic>> years = List.generate(
      6,
      (index) => {
        'year': startYear + index,
        'total': 0,
      },
    );

    for (final row in result) {
      final year = _toInt(row['year']);

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

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  Future<List> getSaleItems({int? catId, Map? date}) async {
    final database = await dbObj.database;
    String sql = """
    SELECT products.name,SUM(purchase_detail.quantity) as quantity,SUM(purchase_detail.quantity*purchase_detail.price) as price
    FROM products,purchase_detail WHERE products.id=purchase_detail.product_id """;
    String endSql = "GROUP BY products.name ORDER BY products.name;";
    if (catId != null) {
      sql += "AND products.category_id=$catId ";
    }
    if (date != null) {
      sql +=
          "AND purchase_detail.created_at>'${date['start']}' AND purchase_detail.created_at<'${date['end']}' ";
    }
    return await database.rawQuery("$sql$endSql");
  }
}
