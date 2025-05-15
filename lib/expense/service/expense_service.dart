import 'package:win_pos/expense/repository/expense_repository.dart';

class ExpenseService {
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  Future<List> getAll() async {
    return _expenseRepository.getAll();
  }

  Future<List> getAllByDate(String startDate,String endDate) async {
    return _expenseRepository.getAllByDate(startDate, endDate);
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
