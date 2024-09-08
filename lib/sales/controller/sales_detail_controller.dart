import 'package:get/get.dart';
import 'package:win_pos/sales/models/sale_detail_model.dart';
import 'package:win_pos/sales/services/sales_detail_service.dart';

class SalesDetailController extends GetxController {
  SalesDetailService salesDetailService = SalesDetailService();

  var saleDatas = <SaleDetailModel>[].obs;

  void getSaleDetail(int id) async {
    var datas = await salesDetailService.getSaleDetail(id);
    saleDatas.clear();
    for (var data in datas) {
      saleDatas.add(SaleDetailModel.fromMap(data));
    }
  }
}
