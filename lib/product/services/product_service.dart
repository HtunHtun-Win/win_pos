import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:win_pos/product/repository/product_repository.dart';
import 'package:win_pos/user/controllers/user_controller.dart';

class ProductService {
  ProductRepository productRepository = ProductRepository();
  UserController userController = Get.find();

  Future<List> getAll({String? input}) async {
    if (input!.isNotEmpty) {
      return await productRepository.getByFilter(input);
    }
    return await productRepository.getAll();
  }

  Future<Map> getByCode(String code) async {
    var data = await productRepository.getByCode(code);
    if (data.isNotEmpty) {
      return data[0];
    }
    return {};
  }

  Future<Map> addProduct(String code, String name, String description,
      int quantity, int categoryId, int purchasePrice, int salePrice) async {
    if (code.isEmpty || name.isEmpty || purchasePrice == 0) {
      return {'msg': 'null'};
    }
    var product = await getByCode(code);
    if (product.isNotEmpty) return {'msg': 'duplicate'};
    var num = await productRepository.addProduct(code, name, description,
        quantity, categoryId, purchasePrice, salePrice);
    await productRepository.addProductLog(
        num, quantity, "opening", userController.current_user["id"]);
    await productRepository.addPurchasePrice(num, quantity, purchasePrice);
    return {'msg': num};
  }

  Future<Map> updateProduct(
    int id,
    String code,
    String name,
    String description,
    int categoryId,
  ) async {
    if (code.isEmpty || name.isEmpty) {
      return {'msg': 'null'};
    }
    var product = await getByCode(code);
    if (product.isNotEmpty) {
      if (product['id'] != id) return {'msg': 'duplicate'};
    }
    var num = await productRepository.updateProduct(
        id, code, name, description, categoryId);
    return {'msg': num};
  }

  Future<void> deleteProduct(int id) async {
    await productRepository.deleteProduct(id);
  }
}
