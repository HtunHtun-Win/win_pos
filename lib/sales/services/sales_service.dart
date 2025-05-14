import 'package:win_pos/sales/repository/sales_repository.dart';
import '../models/cart_model.dart';
import '../models/sale_detail_model.dart';

class SalesService {
  SalesRepository salesRepository = SalesRepository();

  Future<List> getAllProduct({String? input}) async {
    if (input!.isNotEmpty) {
      return await salesRepository.getByFilter(input);
    }
    return [];
  }

  Future<List> getAllVouchers({Map? map}) async {
    if(map!=null){
      return await salesRepository.getVouchersDate(map);
    }
    return await salesRepository.getAllVouchers();
  }

  Future<int> addSale(Map sale, List<CartModel> cart) async {
    int saleId = await salesRepository.addSale(sale, cart);
    return saleId;
  }

  Future<int> deleteSale(int sid,List<SaleDetailModel> items) async {
    salesRepository.deleteSaleVoucher(sid);
    salesRepository.deleteSaleDetail(sid);
    for (var item in items) {
      salesRepository.updateProductQty(item.id!, item.quantity!);
      salesRepository.addProductLog(item.id!, item.quantity!, "sale return", 1);
      salesRepository.returnPprice(item.id!, item.quantity!, item.pprice!);
    }
    return 0;
  }

}
