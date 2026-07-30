import 'package:get/get.dart';
import 'package:win_pos/core/functions/date_range_calc.dart';
import 'package:win_pos/expense/model/expense_model.dart';
import 'package:win_pos/expense/service/expense_service.dart';

class ExpenseController extends GetxController {
  final ExpenseService _expenseService = ExpenseService();
  var expenseList = []; //variable to keep income and expense list
  var totalIncome = 0.obs;
  var totalExpense = 0.obs;
  var totalBalance = 0.obs;
  String date = "today";
  String desc = "all";

  //for pull to refresh
  var showExpenseList = [].obs;
  var descList = [].obs;
  var searchList = [].obs;
  var maxCount = 10;

  // @override
  // void onInit() {
  //   super.onInit();
  //   getAll();
  // }

  Future<void> getAll({Map? date, String? desc}) async {
    maxCount = 10;
    late var datas;
    if (date == null && desc == null) {
      datas = await _expenseService.getAll();
    } else if (date != null && desc == null) {
      datas = await _expenseService.getAllByFilter(date["start"], date["end"],"all");
    } else if (date == null && desc != null) {
      datas = await _expenseService.getAllByDesc(desc);
    }else {
      datas = await _expenseService.getAllByFilter(date?["start"], date?["end"],desc!);
    }
    expenseList.clear();
    totalIncome = 0.obs;
    totalExpense = 0.obs;
    for (var data in datas) {
      expenseList.add(ExpenseModel.fromMap(data));
      if (data['flow_type_id'] == 1) {
        totalIncome += data['amount'];
      } else {
        totalExpense += data['amount'];
      }
    }
    if (expenseList.isNotEmpty) {
      showExpenseList.clear();
      maxCount = expenseList.length < maxCount ? expenseList.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showExpenseList.add(expenseList[i]);
      }
    } else {
      showExpenseList.clear();
    }
    totalBalance.value = totalIncome.value - totalExpense.value;
  }

  Future<void> getAllDesc() async {
    descList.clear();
    var datas = await _expenseService.getAllDesc();
    for (var data in datas) {
      descList.add(data["description"]);
    }
  }

  Future<void> getDescByKeyword(String keyword) async {
    searchList.clear();
    var datas = await _expenseService.getDescByKeyword(keyword);
    for (var data in datas) {
      searchList.add(data["description"]);
    }
  }

  Future<int> updateDesc(String oldValue,String newValue) async {
    searchList.clear();
    return await _expenseService.updateDesc(oldValue, newValue);
  }

  Future<Map> addExpense(
      int amount, String description, String note, int type, int userId) async {
    var num = await _expenseService.addExpense(
        amount, description, note, type, userId);
    if (date == "all") {
      getAll();
    } else {
      getAll(date: daterangeCalculate(date));
    }
    getAllDesc();
    return num;
  }

  Future<Map> updateExpense(int id, int amount, String description, String note,
      int type, int userId) async {
    var num = await _expenseService.updateExpense(
        id, amount, description, note, type, userId);
    if (date == "all") {
      getAll();
    } else {
      getAll(date: daterangeCalculate(date));
    }
    getAllDesc();
    return num;
  }

  Future<void> deleteExpense(int id) async {
    await _expenseService.deleteExpense(id);
    if (date == "all") {
      getAll();
    } else {
      getAll(date: daterangeCalculate(date));
    }
  }

  void loadMore() {
    Future.delayed(const Duration(microseconds: 1000), () {
      int rmData = expenseList.length - maxCount;
      int nextCount = rmData >= 10 ? 10 : rmData;
      for (int i = maxCount; i < maxCount + nextCount; i++) {
        showExpenseList.add(expenseList[i]);
      }
      maxCount += nextCount;
    });
  }
}
