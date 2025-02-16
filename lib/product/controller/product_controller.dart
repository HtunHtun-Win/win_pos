import 'package:get/get.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/product/services/product_service.dart';

class ProductController extends GetxController {
  ProductService productService = ProductService();

  var products = [].obs;

  @override
  void onInit() {
    super.onInit();
    getAll();
  }

  Future<void> getAll({String? input = ''}) async {
    var datas = await productService.getAll(input: input);
    products.clear();
    for (var data in datas) {
      products.add(ProductModel.fromMap(data));
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
      int salePrice
  ) async {
    var map = await productService.updateProduct(
        id, code, name, description, categoryId,salePrice);
    getAll();
    return map;
  }

  Future<void> deleteProduct(ProductModel product) async {
    await productService.deleteProduct(product.id!);
  }
}
