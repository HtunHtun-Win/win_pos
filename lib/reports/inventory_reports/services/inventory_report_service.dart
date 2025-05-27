import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/reports/inventory_reports/models/product_value_model.dart';
import 'package:win_pos/reports/inventory_reports/repository/inventory_report_repository.dart';

class InventoryReportService {
  InventoryReportRepository reportRepository = InventoryReportRepository();

  Future<List> getAll({int? catId}) async {
    var datas = await reportRepository.getAll(catId: catId);
    return datas.map((data) => ProductModel.fromMap(data)).toList();
  }

  Future<List<ProductValueModel>> getWithValue({int? catId}) async {
    var datas = await reportRepository.getWithValue(catId: catId);
    return datas.map((data) => ProductValueModel.fromJson(data)).toList();
  }
}
