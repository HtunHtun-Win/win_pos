import 'package:get/get.dart';
import 'package:win_pos/reports/sale_reports/models/sale_item_model.dart';
import 'package:win_pos/reports/sale_reports/services/sales_report_service.dart';
import '../../../sales/models/sale_model.dart';

class SalesReportController extends GetxController{
  SalesReportService service = SalesReportService();

  var vouchers = <SaleModel>[];
  var items = <SaleItemModel>[];
  var totalAmount = 0.obs;
  var itemTotalAmount = 0.obs;

  //for pull to refresh
  var showVouchers = <SaleModel>[].obs;
  var showItems = <SaleItemModel>[].obs;
  var maxCount = 10;

  Future<void> getAllVouchers({int? customerId,Map? date}) async {
    maxCount = 10;
    vouchers.clear();
    var datas = await service.getAllVouchers(customerId: customerId,date: date);
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

  Future<void> getSaleItems({int? catId,Map? date}) async {
    maxCount = 10;
    items.clear();
    var datas = await service.getSaleItems(catId: catId,date: date);
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