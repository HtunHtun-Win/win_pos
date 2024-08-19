import 'package:get/get.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/sales/services/sales_service.dart';

class SalesController extends GetxController{
  SalesService salesService = SalesService();
  var products = [].obs;
  var cart = [].obs;

  void onInit(){
    super.onInit();
    getAllProduct();
  }

  Future<void> getAllProduct({String? input=''}) async{
    var datas = await salesService.getAllProduct(input: input);
    products.clear();
    for (var data in datas){
      products.add(
        ProductModel.fromMap(data)
      );
    }
  }
}