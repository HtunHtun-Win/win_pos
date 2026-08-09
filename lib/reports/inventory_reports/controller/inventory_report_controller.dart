import 'package:get/get.dart';
import 'package:win_pos/reports/inventory_reports/services/inventory_report_service.dart';

class InventoryReportController extends GetxController {
  InventoryReportService reportService = InventoryReportService();

  var products = [];
  var productsValue = [];
  var saleLog = [];
  var totalValue = 0.obs;

  //for pull to refresh
  var showProducts = [].obs;
  var showProductsValue = [].obs;
  var showSalelog = [].obs;
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

  Future<void> getSaleLog({int? pid,Map? date}) async {
    maxCount = 10;
    saleLog.clear();
    var datas = await reportService.getSalePriceLog(pid: pid,date: date);
    saleLog = datas;
    getTotal();
    if (saleLog.isNotEmpty) {
      showSalelog.clear();
      maxCount = saleLog.length < maxCount ? saleLog.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showSalelog.add(saleLog[i]);
      }
    }else{
      showSalelog.clear();
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

  /// Search products by name or code and update `showProducts`.
  void searchProducts(String key) {
    final q = key.trim().toLowerCase();
    if (q.isEmpty) {
      // restore initial page
      showProducts.clear();
      maxCount = products.length < 10 ? products.length : 10;
      for (int i = 0; i < maxCount; i++) {
        showProducts.add(products[i]);
      }
      return;
    }

    final results = products.where((p) {
      final name = (p.name ?? '').toString().toLowerCase();
      final code = (p.code ?? '').toString().toLowerCase();
      return name.contains(q) || code.contains(q);
    }).toList();

    showProducts.clear();
    for (var r in results) showProducts.add(r);
  }

  /// Search products-with-value by name and update `showProductsValue`.
  void searchProductsValue(String key) {
    final q = key.trim().toLowerCase();
    if (q.isEmpty) {
      showProductsValue.clear();
      maxCount = productsValue.length < 10 ? productsValue.length : 10;
      for (int i = 0; i < maxCount; i++) {
        showProductsValue.add(productsValue[i]);
      }
      return;
    }

    final results = productsValue.where((p) {
      final name = (p.name ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();

    showProductsValue.clear();
    for (var r in results) showProductsValue.add(r);
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

  void saleLogLoadMore() {
    Future.delayed(const Duration(microseconds: 1000), () {
      int rmData = saleLog.length - maxCount;
      int nextCount = rmData >= 10 ? 10 : rmData;
      for (int i = maxCount; i < maxCount + nextCount; i++) {
        showSalelog.add(saleLog[i]);
      }
      maxCount += nextCount;
    });
  }
}
