import 'package:win_pos/purchase/models/purchase_model.dart';
import 'package:win_pos/reports/purchase_reports/models/purchase_item_model.dart';
import '../repository/purchase_report_repository.dart';

class PurchaseReportService {
  PurchaseReportRepository purchaseRepository = PurchaseReportRepository();

  Future<List<PurchaseModel>> getAllVouchers({int? supplierId,Map? date}) async {
    List datas = await purchaseRepository.getAllVouchers(supplierId: supplierId,date: date);
    return datas.map((data)=>PurchaseModel.fromMap(data)).toList();
  }

  Future<List<PurchaseItemModel>> getPurchaseItems({int? catId,Map? date}) async {
    List datas = await purchaseRepository.getSaleItems(catId: catId,date: date);
    return datas.map((data)=>PurchaseItemModel.fromJson(data)).toList();
  }

}
