import 'package:get/get.dart';
import 'package:jue_pos/product/models/product_log_model.dart';
import 'package:jue_pos/product/services/product_log_service.dart';

class ProductLogController extends GetxController {
  ProductLogService productLogService = ProductLogService();
  var logs = [].obs;

  @override
  void onInit(){
    super.onInit();
    getAll();
  }

  Future<void> getAll({Map? map}) async {
    var datas = await productLogService.getAll(map: map);
    logs.clear();
    for (var data in datas) {
      logs.add(ProductLogModel.fromMap(data));
    }
  }
}
