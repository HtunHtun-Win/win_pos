import 'package:win_pos/expense/model/expense_model.dart';
import 'package:win_pos/expense/repository/expense_repository.dart';

class ExpenseService {
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  Future<List> getAll() async {
    return _expenseRepository.getAll();
  }

  Future<List> getAllByDesc(String desc) async{
    return _expenseRepository.getAllByDesc(desc);
  }

  Future<List> getAllDesc() async{
    return _expenseRepository.getAllDesc();
  }

  Future<List> getDescByKeyword(String keyword) async{
    return _expenseRepository.getDescByKeyword(keyword);
  }

  Future<int> updateDesc(String oldValue,String newValue) async{
    return _expenseRepository.updateDesc(oldValue,newValue);
  }

  Future<List> getAllByFilter(String startDate,String endDate,String desc) async {
    return _expenseRepository.getAllByFilter(startDate, endDate,desc);
  }

  Future<Map> addExpense(ExpenseModel model) async {
    // print(amount);
    if (model.amount! > 0 && model.description!.isNotEmpty) {
      await _expenseRepository.addExpense(model);
      return {'msg': 'success'};
    } else {
      return {'msg': 'null'};
    }
  }

  Future<Map> updateExpense(ExpenseModel model) async {
    // print(amount);
    if (model.amount! > 0 && model.description!.isNotEmpty) {
      await _expenseRepository.updateExpense(model);
      return {'msg': 'success'};
    } else {
      return {'msg': 'null'};
    }
  }

  Future<void> deleteExpense(int id) async {
    await _expenseRepository.deleteExpense(id);
  }
}
