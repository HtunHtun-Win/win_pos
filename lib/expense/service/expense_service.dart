import 'package:jue_pos/expense/repository/expense_repository.dart';

class ExpenseService{
  ExpenseRepository _expenseRepository = ExpenseRepository();

  Future<List> getAll() async{
    return _expenseRepository.getAll();
  }

  Future<int> addExpense(int amount, String description, String note, int type, int userId) async{
    var num = await _expenseRepository.addExpense(amount, description, note, type, userId);
    return num;
  }
}