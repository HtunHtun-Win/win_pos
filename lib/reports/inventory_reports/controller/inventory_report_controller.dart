import 'package:get/get.dart';
import 'package:win_pos/reports/inventory_reports/services/inventory_report_service.dart';

class InventoryReportController extends GetxController {
  InventoryReportService reportService = InventoryReportService();

  var products = [];
  var productsValue = [];
  var totalValue = 0.obs;

  //for pull to refresh
  var showProducts = [].obs;
  var showProductsValue = [].obs;
  var maxCount = 10;

  Future<void> getAll({int? catId}) async {
    maxCount = 10;
    products.clear();
    var datas = await reportService.getAll(catId: catId);
    products = datas;
    getTotal();
    if (products.isNotEmpty) {
      showProducts.clear();
      maxCount = products.length < maxCount ? products.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showProducts.add(products[i]);
      }
    } else {
      showProducts.clear();
    }
  }

  Future<void> getWithValue({int? catId}) async {
    maxCount = 10;
    productsValue.clear();
    var datas = await reportService.getWithValue(catId: catId);
    productsValue = datas;
    getTotal();
    if (productsValue.isNotEmpty) {
      showProductsValue.clear();
      maxCount = productsValue.length < maxCount ? productsValue.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showProductsValue.add(productsValue[i]);
      }
    } else {
      showProductsValue.clear();
    }
  }

  void getTotal() {
    int total = 0;
    for (var t in productsValue) {
      total += t.total! as int;
    }
    totalValue.value = total;
  }

  void productLoadMore() {
    Future.delayed(const Duration(microseconds: 1000), () {
      int rmData = products.length - maxCount;
      int nextCount = rmData >= 10 ? 10 : rmData;
      for (int i = maxCount; i < maxCount + nextCount; i++) {
        showProducts.add(products[i]);
      }
      maxCount += nextCount;
    });
  }

  void productValueLoadMore() {
    Future.delayed(const Duration(microseconds: 1000), () {
      int rmData = productsValue.length - maxCount;
      int nextCount = rmData >= 10 ? 10 : rmData;
      for (int i = maxCount; i < maxCount + nextCount; i++) {
        showProductsValue.add(productsValue[i]);
      }
      maxCount += nextCount;
    });
  }
}
