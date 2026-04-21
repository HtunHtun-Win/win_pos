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

  Future<Map> addExpense(
      int amount, String description, String note, int type, int userId) async {
    // print(amount);
    if (amount > 0 && description.isNotEmpty) {
      await _expenseRepository.addExpense(
          amount, description, note, type, userId);
      return {'msg': 'success'};
    } else {
      return {'msg': 'null'};
    }
  }

  Future<Map> updateExpense(int id, int amount, String description, String note,
      int type, int userId) async {
    // print(amount);
    if (amount > 0 && description.isNotEmpty) {
      await _expenseRepository.updateExpense(
          id, amount, description, note, type, userId);
      return {'msg': 'success'};
    } else {
      return {'msg': 'null'};
    }
  }

  Future<void> deleteExpense(int id) async {
    await _expenseRepository.deleteExpense(id);
  }
}
