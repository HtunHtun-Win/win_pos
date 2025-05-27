import 'package:get/get.dart';
import 'package:win_pos/product/models/product_model.dart';
import 'package:win_pos/purchase/models/purchase_detail_model.dart';
import 'package:win_pos/sales/models/cart_model.dart';
import '../models/purchase_model.dart';
import '../services/purchase_service.dart';

class PurchaseController extends GetxController {
  PurchaseService purchaseService = PurchaseService();
  var products = [].obs;
  var cart = <CartModel>[].obs;
  var vouchers = <PurchaseModel>[];
  var totalAmount = 0.obs;
  var discount = 0.obs;

  //for pull to refresh
  var showVouchers = <PurchaseModel>[].obs;
  var maxCount = 10;
  String selectedDate = "today";

  Future<void> getAllProduct({String? input = ''}) async {
    var datas = await purchaseService.getAllProduct(input: input);
    products.clear();
    for (var data in datas) {
      products.add(ProductModel.fromMap(data));
    }
  }

  Future<void> getAllVouchers({Map? map}) async {
    maxCount = 10; // reset maxCount for new fetch
    var datas = await purchaseService.getAllVouchers(map: map);
    vouchers.clear();
    for (var data in datas) {
      vouchers.add(PurchaseModel.fromMap(data));
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
        'pprice': product.purchase_price,
      }));
    }
  }

  Future<int> addPurchase(Map purchase, List<CartModel> cart) async {
    int saleId = await purchaseService.addPurchase(purchase, cart);
    return saleId;
  }

  Future<int> deletePurchase(int vid, List<PurchaseDetailModel> items) async {
    int saleId = await purchaseService.deletePurchase(vid, items);
    return saleId;
  }

  void getTotal() {
    totalAmount.value = 0;
    for (var item in cart) {
      totalAmount += item.pprice! * item.quantity;
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
