import 'package:jue_pos/product/repository/product_log_repository.dart';

class ProductLogService {
  ProductLogRepository productLogRepository = ProductLogRepository();

  Future<List> getAll({Map? map}) async {
    if(map!=null){
      return await productLogRepository.getByDate(map);
    }
    return await productLogRepository.getAll();
  }
}
