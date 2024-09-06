import 'package:get/get.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/sales/models/cart_model.dart';
import 'package:win_pos/sales/services/sales_service.dart';

class SalesController extends GetxController{
  SalesService salesService = SalesService();
  var products = [].obs;
  var cart = <CartModel>[].obs;
  var tempCart = <CartModel>[].obs;
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

  void addToCart(ProductModel product){
    bool isContain = false;
    for(var item in cart ){
      print(item.product!.id);
      if(item.product!.id == product.id){
        isContain=true;
        break;
      };
    }
    if(!isContain){
      cart.add(
          CartModel.fromMap(
              {
                "product" : product,
                'quantity' : 1,
                'sprice' : product.sale_price
              }
          )
      );
    }
  }

  void getTotal(){
    totalAmount.value = 0;
    for(var item in cart ) {
      totalAmount += item.product!.sale_price! * item.quantity!;
    }
  }

}