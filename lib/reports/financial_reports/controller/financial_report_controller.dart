import 'package:get/get.dart';
import 'package:win_pos/reports/financial_reports/models/profit_lose_model.dart';
import 'package:win_pos/reports/financial_reports/services/financial_report_service.dart';
import '../../../sales/models/sale_model.dart';

class FinancialReportController extends GetxController{
  FinancialReportService service = FinancialReportService();

  var vouchers = <SaleModel>[].obs;
  var totalAmount = 0.obs;
  var profitLose = <ProfitLoseModel>[].obs;

  Future<void> getBankPayment({int? paymentId, Map? date}) async {
    vouchers.clear();
    var datas = await service.getBankPayment(paymentId: paymentId,date: date);
    vouchers.value = datas;
    getTotal();
  }

  void getTotal(){
    int total = 0;
    for(var t in vouchers){
      total += t.total_price!;
    }
    totalAmount.value = total;
  }

  void getProfitLose(Map date) async {
    var datas = await service.getProfitLose(date);
    profitLose.clear();
    for(var data in datas){
      profitLose.add(ProfitLoseModel.fromJson(data));
    }
  }
}