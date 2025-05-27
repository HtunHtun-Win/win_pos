import 'package:get/get.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/product/services/product_service.dart';

class ProductController extends GetxController {
  ProductService productService = ProductService();

  var products = [];
  var purchasePriceLog = [].obs;
  //for pull to refresh
  var showProducts = [].obs;
  var maxCount = 10;
  String searchKeywork='';

  @override
  void onInit() {
    super.onInit();
    getAll();
  }

  Future<void> getAll({String? input = ''}) async {
    maxCount = 10; // reset maxCount for new fetch
    var datas = await productService.getAll(input: input);
    products.clear();
    for (var data in datas) {
      products.add(ProductModel.fromMap(data));
    }
    if (products.isNotEmpty) {
      showProducts.clear();
      maxCount = products.length < maxCount ? products.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showProducts.add(products[i]);
      }
    }
  }

  Future<void> getPurchasePriceLog(int pid) async {
    var datas = await productService.getPurchasePriceLog(pid);
    purchasePriceLog.clear();
    for (var data in datas) {
      purchasePriceLog.add(data);
    }
  }

  Future<Map> addProduct(String code, String name, String description,
      int quantity, int categoryId, int purchasePrice, int salePrice) async {
    var map = await productService.addProduct(code, name, description, quantity,
        categoryId, purchasePrice, salePrice);
    getAll();
    return map;
  }

  Future<Map> updateProduct(
    int id,
    String code,
    String name,
    String description,
    int categoryId,
    int salePrice,
    int oldPrice,
  ) async {
    var map = await productService.updateProduct(
      id,
      code,
      name,
      description,
      categoryId,
      salePrice,
      oldPrice,
    );
    return map;
  }

  Future<void> deleteProduct(ProductModel product) async {
    await productService.deleteProduct(product.id!);
  }

  //clear 0 quantity in purchase price
  Future<void> clearZeroQty() async {
    await productService.clearZeroQty();
  }

  void loadMore() {
    Future.delayed(const Duration(microseconds: 1000), () {
      int rmData = products.length - maxCount;
      int nextCount = rmData >= 10 ? 10 : rmData;
      for (int i = maxCount; i < maxCount + nextCount; i++) {
        showProducts.add(products[i]);
      }
      maxCount += nextCount;
    });
  }
}
