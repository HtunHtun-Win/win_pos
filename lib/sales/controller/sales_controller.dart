import 'package:get/get.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/sales/models/cart_model.dart';
import 'package:win_pos/sales/models/sale_detail_model.dart';
import 'package:win_pos/sales/services/sales_service.dart';
import '../models/sale_model.dart';

class SalesController extends GetxController {
  SalesService salesService = SalesService();
  var products = [].obs;
  var cart = <CartModel>[].obs;
  var vouchers = <SaleModel>[];
  var totalAmount = 0.obs;
  var discount = 0.obs;
  String selectedDate = 'today';

  //for pull to refresh
  var showVouchers = <SaleModel>[].obs;
  var maxCount = 10;

  Future<void> getAllProduct({String? input = ''}) async {
    var datas = await salesService.getAllProduct(input: input);
    products.clear();
    for (var data in datas) {
      products.add(ProductModel.fromMap(data));
    }
  }

  Future<void> getAllVouchers({Map? map}) async {
    maxCount = 10; // reset maxCount for new fetch
    var datas = await salesService.getAllVouchers(map: map);
    vouchers.clear();
    for (var data in datas) {
      vouchers.add(SaleModel.fromMap(data));
    }
    if (vouchers.isNotEmpty) {
      showVouchers.clear();
      maxCount = vouchers.length < maxCount ? vouchers.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showVouchers.add(vouchers[i]);
      }
    }else{
      showVouchers.clear();
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

  Future<int> addSale(Map sale, List<CartModel> cart) async {
    int saleId = await salesService.addSale(sale, cart);
    return saleId;
  }

  Future<int> deleteSale(int sid, List<SaleDetailModel> items) async {
    int saleId = await salesService.deleteSale(sid, items);
    return saleId;
  }

  void getTotal() {
    totalAmount.value = 0;
    for (var item in cart) {
      totalAmount += item.product.sale_price! * item.quantity;
    }
  }

  void loadMore() {
    Future.delayed(const Duration(microseconds: 1000), () {
      int rmData = vouchers.length - maxCount;
      int nextCount = rmData >= 10 ? 10 : rmData;
      for (int i = maxCount; i < maxCount + nextCount; i++) {
        showVouchers.add(vouchers[i]);
      }
      maxCount += nextCount;
    });
  }
}
