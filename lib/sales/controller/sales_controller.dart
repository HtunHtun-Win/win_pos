import 'package:get/get.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/sales/services/sales_service.dart';

class SalesController extends GetxController{
  SalesService salesService = SalesService();
  var products = [].obs;
  var cart = {}.obs;
  var selectedProduct = [].obs;
  var totalAmount = 0.obs;
  var discount = 0.obs;

  Future<void> getAllProduct({String? input=''}) async{
    var datas = await salesService.getAllProduct(input: input);
    products.clear();
    for (var data in datas){
      products.add(
        ProductModel.fromMap(data)
      );
    }
  }

  Future<void> addToSelectedProduct() async{
    selectedProduct.clear();
    cart.forEach((key, value) async{
      int id = int.parse(key);
      var data = await salesService.getById(id);
      totalAmount += data[0]["sale_price"]! * cart[data[0]["id"].toString()];
      selectedProduct.add(
          ProductModel.fromMap(data[0])
      );
    });
  }
}