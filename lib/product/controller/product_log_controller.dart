import 'package:get/get.dart';
import 'package:win_pos/product/controller/product_controller.dart';
import 'package:win_pos/product/models/product_log_model.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/product/services/product_log_service.dart';

class ProductLogController extends GetxController {
  ProductLogService productLogService = ProductLogService();
  ProductController productController = Get.find();
  var logs = [];
  var products = [].obs;
  var selectedProduct = {'pid': 0, 'qty': 0}.obs;

  //for pull to refresh
  var showLogs = [].obs;
  var maxCount = 10;

  @override
  void onInit() {
    super.onInit();
    getAll();
  }

  Future<void> getAll({Map? map}) async {
    var datas = await productLogService.getAll(map: map);
    //for adjust screen to search product
    var pdatas = await productLogService.getAllProduct();
    logs.clear();
    products.clear();
    for (var data in datas) {
      logs.add(ProductLogModel.fromMap(data));
    }
    for (var pdata in pdatas) {
      products.add(ProductModel.fromMap(pdata));
    }
    //add data to show
    if (logs.isNotEmpty) {
      showLogs.clear();
      maxCount = logs.length < maxCount ? logs.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showLogs.add(logs[i]);
      }
    } else {
      showLogs.clear();
    }
  }

  Future<void> getAllLog({Map? map, required int pid}) async {
    var datas = await productLogService.getAllLog(map: map, pid: pid);
    var pdatas = await productLogService.getAllProduct();
    logs.clear();
    // products.clear();
    for (var data in datas) {
      logs.add(ProductLogModel.fromMap(data));
    }
    // for (var pdata in pdatas) {
    //   products.add(ProductModel.fromMap(pdata));
    // }
    if (logs.isNotEmpty) {
      showLogs.clear();
      maxCount = logs.length < maxCount ? logs.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showLogs.add(logs[i]);
      }
    } else {
      showLogs.clear();
    }
  }

  void clearSelected() {
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

  void loadMore() {
    Future.delayed(const Duration(microseconds: 1000), () {
      int rmData = logs.length - maxCount;
      int nextCount = rmData >= 10 ? 10 : rmData;
      for (int i = maxCount; i < maxCount + nextCount; i++) {
        showLogs.add(logs[i]);
      }
      maxCount += nextCount;
    });
  }
}
