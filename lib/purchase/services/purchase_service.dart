import 'package:win_pos/purchase/models/purchase_detail_model.dart';
import 'package:win_pos/purchase/repository/purchase_repository.dart';
import '../../sales/models/cart_model.dart';

class PurchaseService {
  PurchaseRepository purchaseRepository = PurchaseRepository();

  Future<List> getAllProduct({String? input}) async {
    if (input!.isNotEmpty) {
      return await purchaseRepository.getByFilter(input);
    }
    return [];
  }

  Future<List> getAllVouchers({Map? map}) async {
    if (map != null) {
      return await purchaseRepository.getVouchersDate(map);
    }
    return await purchaseRepository.getAllVouchers();
  }

  Future<int> addPurchase(Map purchase, List<CartModel> cart) async {
    int saleId = await purchaseRepository.addPurchase(purchase, cart);
    return saleId;
  }

  Future<int> deletePurchase(int vid,List<PurchaseDetailModel> items) async {
    purchaseRepository.deletePurchaseVoucher(vid);
    purchaseRepository.deletePurchaseDetail(vid);
    for (var item in items) {
      purchaseRepository.updateProduct(item.id!, -item.quantity!,item.price!);
      purchaseRepository.removePprice(item.id!, item.quantity!);
      purchaseRepository.addProductLog(item.id!, -item.quantity!, "purchase return", 1);
    }
    return 0;
  }
}
