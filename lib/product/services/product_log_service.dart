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

  Future<List> getAllProduct() async {
    return await productRepository.getAll();
  }

  Future<void> addProductLog(int productId,int quantity,String note,int userId) async{
    await productRepository.addProductLog(productId, quantity, note, userId);
  }

  Future<int> updateProductQty(int id, int qty) async{
    final num = productRepository.updateProductQty(id, qty);
    return num;
  }
}
