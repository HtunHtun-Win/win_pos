import 'package:win_pos/purchase/repository/purchase_repository.dart';
import '../../sales/models/cart_model.dart';

class PurchaseService {
  PurchaseRepository purchaseService = PurchaseRepository();

  Future<List> getAllProduct({String? input}) async {
    if (input!.isNotEmpty) {
      return await purchaseService.getByFilter(input);
    }
    return [];
  }

  Future<List> getAllVouchers({Map? map}) async {
    if (map != null) {
      return await purchaseService.getVouchersDate(map);
    }
    return await purchaseService.getAllVouchers();
  }

  Future<int> addPurchase(Map purchase, List<CartModel> cart) async {
    int saleId = await purchaseService.addPurchase(purchase, cart);
    return saleId;
  }
}
