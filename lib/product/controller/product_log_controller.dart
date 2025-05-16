import 'package:get/get.dart';
import 'package:win_pos/product/controller/product_controller.dart';
import 'package:win_pos/product/models/product_log_model.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/product/services/product_log_service.dart';

class ProductLogController extends GetxController {
  ProductLogService productLogService = ProductLogService();
  ProductController productController = Get.find();
  var logs = [].obs;
  var products = [].obs;
  var selectedProduct = {'pid': 0, 'qty': 0}.obs;

  @override
  void onInit() {
    super.onInit();
    getAll();
  }

  Future<void> getAll({Map? map}) async {
    var datas = await productLogService.getAll(map: map);
    var pdatas = await productLogService.getAllProduct();
    logs.clear();
    products.clear();
    for (var data in datas) {
      logs.add(ProductLogModel.fromMap(data));
    }
    for (var pdata in pdatas) {
      products.add(ProductModel.fromMap(pdata));
    }
  }

  Future<void> getAllLog({Map? map,required int pid}) async {
    var datas = await productLogService.getAllLog(map: map,pid: pid);
    var pdatas = await productLogService.getAllProduct();
    logs.clear();
    products.clear();
    for (var data in datas) {
      logs.add(ProductLogModel.fromMap(data));
    }
    for (var pdata in pdatas) {
      products.add(ProductModel.fromMap(pdata));
    }
  }

  void clearSelected(){
    selectedProduct = {'pid': 0, 'qty': 0}.obs;
  }

  Future<void> addProductLog(
      int productId, int quantity, String note, int userId) async {
    await productLogService.addProductLog(productId, quantity, note, userId);
    await productLogService.updateProductQty(productId, quantity);
    clearSelected();
    await productController.getAll();
    getAll();
  }
}
