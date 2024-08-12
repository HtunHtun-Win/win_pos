import 'package:get/get.dart';
import 'package:jue_pos/product/models/product_model.dart';
import 'package:jue_pos/product/services/product_service.dart';

class ProductController extends GetxController{

  ProductService productService = ProductService();

  var products = [].obs;

  @override
  void onInit(){
    super.onInit();
    getAll();
  }

  Future<void> getAll({String? input=''}) async{
    var datas = await productService.getAll(input: input);
    products.clear();
    for (var data in datas) {
      products.add(ProductModel.fromMap(data));
    }
  }

  Future<Map> addProduct(String code, String name,String description,int quantity,int category_id,int purchase_price,int sale_price) async{
    var map = await productService.addProduct(code, name, description, quantity, category_id, purchase_price, sale_price);
    getAll();
    return map;
  }

  Future<Map> updateProduct(int id, String code, String name,String description,int category_id,) async{
    var map = await productService.updateProduct(id, code, name, description, category_id);
    getAll();
    return map;
  }

  Future<void> deleteProduct(ProductModel product) async{
    await productService.deleteProduct(product.id!);
  }

}