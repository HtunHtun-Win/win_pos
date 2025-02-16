import 'package:win_pos/reports/sale_reports/models/sale_item_model.dart';
import 'package:win_pos/reports/sale_reports/repository/sales_report_repository.dart';
import 'package:win_pos/sales/models/sale_model.dart';

class SalesReportService {
  SalesReportRepository salesRepository = SalesReportRepository();

  Future<List<SaleModel>> getAllVouchers({int? customerId,Map? date}) async {
    List datas = await salesRepository.getAllVouchers(customerId: customerId,date: date);
    return datas.map((data)=>SaleModel.fromMap(data)).toList();
  }

  Future<List<SaleItemModel>> getSaleItems({int? catId,Map? date}) async {
    List datas = await salesRepository.getSaleItems(catId: catId,date: date);
    return datas.map((data)=>SaleItemModel.fromJson(data)).toList();
  }

}
