import 'package:get/get.dart';
import 'package:win_pos/purchase/models/purchase_model.dart';
import 'package:win_pos/reports/purchase_reports/models/purchase_item_model.dart';
import 'package:win_pos/reports/purchase_reports/services/purchase_report_service.dart';

class PurchaseReportController extends GetxController{
  PurchaseReportService service = PurchaseReportService();

  var vouchers = <PurchaseModel>[].obs;
  var items = <PurchaseItemModel>[].obs;
  var totalAmount = 0.obs;
  var itemTotalAmount = 0.obs;

  Future<void> getAllVouchers({int? supplierId,Map? date}) async {
    vouchers.clear();
    var datas = await service.getAllVouchers(supplierId: supplierId,date: date);
    vouchers.value = datas;
    getTotal();
  }

  Future<void> getPurchaseItems({int? catId,Map? date}) async {
    items.clear();
    var datas = await service.getPurchaseItems(catId: catId,date: date);
    items.value = datas;
    itemTotal();
  }

  int? getTotal(){
    int total = 0;
    for(var t in vouchers){
      total += t.total_price!;
    }
    totalAmount.value = total;
    return totalAmount.value;
  }

  int? itemTotal(){
    int total = 0;
    for(var t in items){
      total += t.price;
    }
    itemTotalAmount.value = total;
    return itemTotalAmount.value;
  }
}