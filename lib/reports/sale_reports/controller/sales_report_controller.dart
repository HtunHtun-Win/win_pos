import 'package:get/get.dart';
import 'package:win_pos/reports/sale_reports/models/sale_item_model.dart';
import 'package:win_pos/reports/sale_reports/services/sales_report_service.dart';
import '../../../sales/models/sale_model.dart';

class SalesReportController extends GetxController{
  SalesReportService service = SalesReportService();

  var vouchers = <SaleModel>[].obs;
  var items = <SaleItemModel>[].obs;
  var totalAmount = 0.obs;
  var itemTotalAmount = 0.obs;

  Future<void> getAllVouchers({int? customerId,Map? date}) async {
    vouchers.clear();
    var datas = await service.getAllVouchers(customerId: customerId,date: date);
    vouchers.value = datas;
    getTotal();
  }

  Future<void> getSaleItems({int? catId,Map? date}) async {
    items.clear();
    var datas = await service.getSaleItems(catId: catId,date: date);
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