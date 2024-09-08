import 'package:win_pos/purchase/repository/purchase_detail_repository.dart';

class PurchaseDetailService {
  PurchaseDetailRepository purchaseDetailRepository =
      PurchaseDetailRepository();

  Future<List> getPurchaseDetail(int phid) async {
    return await purchaseDetailRepository.getPurchaseDetail(phid);
  }
}
