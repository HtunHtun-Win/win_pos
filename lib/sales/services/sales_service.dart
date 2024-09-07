import 'package:win_pos/contact/customer/model/customer_model.dart';
import 'package:win_pos/sales/repository/sales_repository.dart';

import '../models/cart_model.dart';
import '../models/sale_model.dart';

class SalesService {
  SalesRepository salesRepository = SalesRepository();

  Future<List> getAllProduct({String? input}) async {
    if (input!.length > 0) {
      return await salesRepository.getByFilter(input);
    }
    return [];
  }

  Future<List> getAllVouchers() async {
    return await salesRepository.getAllVouchers();
  }

  Future<List> getById(int id) async {
    return await salesRepository.getById(id);
  }

  Future<int> addSale(SaleModel sale, List<CartModel> cart) async {
    int saleId = await salesRepository.addSale(sale, cart);
    return saleId;
  }

  Future<List> getCustomer() async {
    return await salesRepository.getCustomer();
  }
}
