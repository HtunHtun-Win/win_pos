import 'package:win_pos/reports/sale_reports/models/sale_item_model.dart';
import 'package:win_pos/reports/sale_reports/models/vip_customer_model.dart';
import 'package:win_pos/reports/sale_reports/repository/sales_report_repository.dart';
import 'package:win_pos/sales/models/sale_model.dart';

class SalesReportService {
  SalesReportRepository salesRepository = SalesReportRepository();

  Future<List<SaleModel>> getAllVouchers({int? customerId, Map? date}) async {
    List datas = await salesRepository.getAllVouchers(
        customerId: customerId, date: date);
    return datas.map((data) => SaleModel.fromMap(data)).toList();
  }

  Future<List<VipCustomerModel>> getVipCustomer({int? customerId, Map? date}) async {
    List datas = await salesRepository.getVipCustomer(date: date);
    return datas.map((data) => VipCustomerModel.fromJson(data)).toList();
  }

  Future<List<SaleItemModel>> getSaleItems({int? catId, Map? date}) async {
    List datas = await salesRepository.getSaleItems(catId: catId, date: date);
    return datas.map((data) => SaleItemModel.fromJson(data)).toList();
  }

  Future<List<SaleItemModel>> getMostSaleItems({int? catId, Map? date}) async {
    List datas =
        await salesRepository.getMostSaleItems(catId: catId, date: date);
    return datas.map((data) => SaleItemModel.fromJson(data)).toList();
  }

  Future<List<Map<String, dynamic>>> getMonthlySales({
    int? year,
  }) async {
    return await salesRepository.getMonthlySales(year: year);
  }

  Future<List<Map<String, dynamic>>> getYearlySales({
    int? year,
  }) async {
    return await salesRepository.getYearlySales();
  }
}
