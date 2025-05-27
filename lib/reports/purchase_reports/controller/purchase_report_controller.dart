import 'package:get/get.dart';
import 'package:win_pos/purchase/models/purchase_model.dart';
import 'package:win_pos/reports/purchase_reports/models/purchase_item_model.dart';
import 'package:win_pos/reports/purchase_reports/services/purchase_report_service.dart';

class PurchaseReportController extends GetxController{
  PurchaseReportService service = PurchaseReportService();

  var vouchers = <PurchaseModel>[];
  var items = <PurchaseItemModel>[];
  var totalAmount = 0.obs;
  var itemTotalAmount = 0.obs;

  //for pull to refresh
  var showVouchers = <PurchaseModel>[].obs;
  var showItems = <PurchaseItemModel>[].obs;
  var maxCount = 10;

  Future<void> getAllVouchers({int? supplierId,Map? date}) async {
    maxCount = 10;
    vouchers.clear();
    var datas = await service.getAllVouchers(supplierId: supplierId,date: date);
    vouchers = datas;
    getTotal();
    if (vouchers.isNotEmpty) {
      showVouchers.clear();
      maxCount = vouchers.length < maxCount ? vouchers.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showVouchers.add(vouchers[i]);
      }
    }else{
      showVouchers.clear();
    }
  }

  Future<void> getPurchaseItems({int? catId,Map? date}) async {
    maxCount = 10;
    items.clear();
    var datas = await service.getPurchaseItems(catId: catId,date: date);
    items = datas;
    itemTotal();
    if (items.isNotEmpty) {
      showItems.clear();
      maxCount = items.length < maxCount ? items.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showItems.add(items[i]);
      }
    }else{
      showItems.clear();
    }
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

  void voucherLoadMore() {
    Future.delayed(const Duration(microseconds: 1000), () {
      int rmData = vouchers.length - maxCount;
      int nextCount = rmData >= 10 ? 10 : rmData;
      for (int i = maxCount; i < maxCount + nextCount; i++) {
        showVouchers.add(vouchers[i]);
      }
      maxCount += nextCount;
    });
  }

  void itemLoadMore() {
    Future.delayed(const Duration(microseconds: 1000), () {
      int rmData = items.length - maxCount;
      int nextCount = rmData >= 10 ? 10 : rmData;
      for (int i = maxCount; i < maxCount + nextCount; i++) {
        showItems.add(items[i]);
      }
      maxCount += nextCount;
    });
  }
}