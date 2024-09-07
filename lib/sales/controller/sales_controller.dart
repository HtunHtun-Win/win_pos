import 'package:get/get.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/sales/models/cart_model.dart';
import 'package:win_pos/sales/services/sales_service.dart';
import '../models/sale_model.dart';

class SalesController extends GetxController {
  SalesService salesService = SalesService();
  var products = [].obs;
  var cart = <CartModel>[].obs;
  var vouchers = <SaleModel>[].obs;
  var customers = {}.obs;
  var totalAmount = 0.obs;
  var discount = 0.obs;

  Future<void> getAllProduct({String? input = ''}) async {
    var datas = await salesService.getAllProduct(input: input);
    products.clear();
    for (var data in datas) {
      products.add(ProductModel.fromMap(data));
    }
  }

  Future<void> getAllVouchers() async {
    var datas = await salesService.getAllVouchers();
    vouchers.clear();
    for (var data in datas) {
      vouchers.add(SaleModel.fromMap(data));
    }
  }

  void addToCart(ProductModel product) {
    bool isContain = false;
    for (var item in cart) {
      if (item.product.id == product.id) {
        isContain = true;
        break;
      }
    }
    if (!isContain) {
      cart.add(CartModel.fromMap({
        "product": product,
        'quantity': 1,
        'sprice': product.sale_price,
      }));
    }
  }

  Future<int> addSale(SaleModel sale, List<CartModel> cart) async {
    int saleId = await salesService.addSale(sale, cart);
    return saleId;
  }

  void getCustomer() async {
    var datas = await salesService.getCustomer();
    for (var data in datas) {
      customers[data['id']] = data['name'];
    }
  }

  void getTotal() {
    totalAmount.value = 0;
    for (var item in cart) {
      totalAmount += item.product.sale_price! * item.quantity;
    }
  }
}
