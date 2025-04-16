import 'package:get/get.dart';
import 'package:win_pos/expense/model/expense_model.dart';
import 'package:win_pos/expense/service/expense_service.dart';

class ExpenseController extends GetxController {
  final ExpenseService _expenseService = ExpenseService();
  var expense_list = [].obs; //variable to keep income and expense list
  var totalIncome = 0.obs;
  var totalExpense = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getAll();
  }

  Future<void> getAll({Map? date}) async {
    late var datas;
    if(date==null){
      datas = await _expenseService.getAll();
    }else{
      datas = await _expenseService.getAllByDate(date["start"], date["end"]);
    }
    expense_list.clear();
    totalIncome = 0.obs;
    totalExpense = 0.obs;
    for (var data in datas) {
      expense_list.add(ExpenseModel.fromMap(data));
      if (data['flow_type_id'] == 1) {
        totalIncome += data['amount'];
      } else {
        totalExpense += data['amount'];
      }
    }
  }

  Future<Map> addExpense(
      int amount, String description, String note, int type, int userId) async {
    var num = await _expenseService.addExpense(
        amount, description, note, type, userId);
    getAll();
    return num;
  }

  Future<Map> updateExpense(int id, int amount, String description, String note,
      int type, int userId) async {
    var num = await _expenseService.updateExpense(
        id, amount, description, note, type, userId);
    getAll();
    return num;
  }

  Future<void> deleteExpense(int id) async {
    await _expenseService.deleteExpense(id);
    getAll();
  }
}
