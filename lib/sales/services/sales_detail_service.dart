import 'package:win_pos/sales/repository/sale_detail_repository.dart';

class SalesDetailService {
  SaleDetailRepository saleDetailRepository = SaleDetailRepository();

  Future<List> getSaleDetail(int sid) async {
    return await saleDetailRepository.getSaleDetail(sid);
  }
}
