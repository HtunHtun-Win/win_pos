import 'dart:math';

import 'package:win_pos/product/repository/product_log_repository.dart';
import 'package:win_pos/product/repository/product_repository.dart';

class ProductLogService {
  ProductLogRepository productLogRepository = ProductLogRepository();
  ProductRepository productRepository = ProductRepository();

  Future<List> getAll({Map? map}) async {
    if(map!=null){
      return await productLogRepository.getByDate(map);
    }
    return await productLogRepository.getAll();
  }

  Future<List> getAllLog({Map? map,required int pid}) async {
    if(map!=null){
      return await productLogRepository.getAllLogByDate(map,pid);
    }
    return await productLogRepository.getAllLog(pid: pid);
  }

  Future<List> getAllProduct() async {
    return await productRepository.getAll();
  }

  Future<void> addProductLog(int productId,int quantity,String note,int userId) async{
    await productRepository.addProductLog(productId, quantity, note, userId);
  }

  Future<int> updateProductQty(int id, int qty) async{
    final num = await productRepository.updateProductQty(id, qty);
      if(qty>0){
        await productRepository.updatePurchasePriceQty(id, qty);
      }else{
        int tempQty = qty.abs();
        bool flag = true;
        while(flag){
          var pprice = await productRepository.getPprice(id);
          if(pprice['quantity'] >= tempQty){
            await productRepository.updatePurchasePriceQty(id, -tempQty);
            tempQty = 0;
          }else{
            await productRepository.updatePurchasePriceQty(id, -pprice['quantity']);
            tempQty -= pprice['quantity'] as int;
          }
          if(tempQty==0) flag = false;
      }
    }
    return num;
  }
}
