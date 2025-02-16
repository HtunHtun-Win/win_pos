import 'package:win_pos/reports/financial_reports/models/profit_lose_model.dart';
import 'package:win_pos/reports/financial_reports/repository/financial_report_repository.dart';
import '../../../sales/models/sale_model.dart';

class FinancialReportService {
  FinancialReportRepository financialReportRepository = FinancialReportRepository();

  Future<List<SaleModel>> getBankPayment({int? paymentId, Map? date}) async {
    List datas = await financialReportRepository.getBankPayment(paymentId: paymentId,date: date);
    return datas.map((data)=>SaleModel.fromMap(data)).toList();
  }

  Future<List> getProfitLose(Map date) async {
    var datas = await financialReportRepository.getProfitLose(date);
    return datas;
  }

}
