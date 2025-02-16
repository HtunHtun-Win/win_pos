import 'package:win_pos/sales/repository/sales_repository.dart';
import '../models/cart_model.dart';

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

}
