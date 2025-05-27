import 'package:get/get.dart';
import 'package:win_pos/reports/financial_reports/models/profit_lose_model.dart';
import 'package:win_pos/reports/financial_reports/services/financial_report_service.dart';
import '../../../sales/models/sale_model.dart';

class FinancialReportController extends GetxController {
  FinancialReportService service = FinancialReportService();

  var vouchers = <SaleModel>[];
  var totalAmount = 0.obs;
  var profitLose = <ProfitLoseModel>[].obs;

  //for pull to refresh
  var showVouchers = <SaleModel>[].obs;
  var maxCount = 10;

  Future<void> getBankPayment({int? paymentId, Map? date}) async {
    maxCount = 10;
    vouchers.clear();
    var datas = await service.getBankPayment(paymentId: paymentId, date: date);
    vouchers = datas;
    getTotal();
    if (vouchers.isNotEmpty) {
      showVouchers.clear();
      maxCount = vouchers.length < maxCount ? vouchers.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showVouchers.add(vouchers[i]);
      }
    } else {
      showVouchers.clear();
    }
  }

  void getTotal() {
    int total = 0;
    for (var t in vouchers) {
      total += t.total_price!;
    }
    totalAmount.value = total;
  }

  void getProfitLose(Map date) async {
    var datas = await service.getProfitLose(date);
    profitLose.clear();
    for (var data in datas) {
      profitLose.add(ProfitLoseModel.fromJson(data));
    }
  }

  void loadMore() {
    Future.delayed(const Duration(microseconds: 1000), () {
      int rmData = vouchers.length - maxCount;
      int nextCount = rmData >= 10 ? 10 : rmData;
      for (int i = maxCount; i < maxCount + nextCount; i++) {
        showVouchers.add(vouchers[i]);
      }
      maxCount += nextCount;
    });
  }
}
