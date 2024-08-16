import 'package:jue_pos/expense/repository/expense_repository.dart';

class ExpenseService{
  ExpenseRepository _expenseRepository = ExpenseRepository();

  Future<List> getAll() async{
    return _expenseRepository.getAll();
  }

  Future<Map> addExpense(int amount, String description, String note, int type, int userId) async{
    print(amount);
    if(amount>0 && description.length>0){
      var num = await _expenseRepository.addExpense(amount, description, note, type, userId);
      return {'msg':'success'};
    }else{
      return {'msg':'null'};
    }
  }

  Future<Map> updateExpense(int id, int amount, String description, String note, int type, int userId) async{
    print(amount);
    if(amount>0 && description.length>0){
      var num = await _expenseRepository.updateExpense(id, amount, description, note, type, userId);
      return {'msg':'success'};
    }else{
      return {'msg':'null'};
    }
  }

  Future<void> deleteExpense(int id) async{
    await _expenseRepository.deleteExpense(id);
  }
}