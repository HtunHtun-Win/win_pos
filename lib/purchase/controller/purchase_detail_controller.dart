import 'package:get/get.dart';
import '../models/purchase_detail_model.dart';
import '../services/purchase_detail_service.dart';

class PurchaseDetailController extends GetxController {
  PurchaseDetailService salesDetailService = PurchaseDetailService();

  var saleDatas = <PurchaseDetailModel>[].obs;

  void getPurchaseDetail(int id) async {
    var datas = await salesDetailService.getPurchaseDetail(id);
    saleDatas.clear();
    for (var data in datas) {
      saleDatas.add(PurchaseDetailModel.fromMap(data));
    }
  }
}
