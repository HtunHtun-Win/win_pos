import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:win_pos/reports/inventory_reports/services/inventory_report_service.dart';

class InventoryReportController extends GetxController{
  InventoryReportService reportService = InventoryReportService();

  var products = [].obs;
  var productsValue = [].obs;
  var totalValue = 0.obs;

  Future<void> getAll({int? catId}) async {
    var datas = await reportService.getAll(catId: catId);
    products.clear();
    for(var item in datas){
      products.add(item);
    }
  }

  Future<void> getWithValue({int? catId}) async {
    var datas = await reportService.getWithValue(catId: catId);
    productsValue.clear();
    for(var item in datas){
      productsValue.add(item);
    }
    getTotal();
  }

  void getTotal(){
    int total = 0;
    for(var t in productsValue){
      total += t.total! as int;
    }
    totalValue.value = total;
  }
}