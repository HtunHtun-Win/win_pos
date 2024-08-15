import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:jue_pos/expense/model/expense_model.dart';
import 'package:jue_pos/expense/service/expense_service.dart';

class ExpenseController extends GetxController{
  ExpenseService _expenseService = ExpenseService();
  var expense_list = [].obs; //variable to keep income and expense list 

  @override
  void onInit(){
    super.onInit();
    getAll();
  }
  
  Future<void> getAll() async{
    var datas = await _expenseService.getAll();
    expense_list.clear();
    for(var data in datas){
      expense_list.add(
        ExpenseModel.fromMap(data)
      );
    }
  }

  Future<int> addExpense(int amount, String description, String note, int type, int userId) async{
    var num = await _expenseService.addExpense(amount, description, note, type, userId);
    getAll();
    return num;
  }
}