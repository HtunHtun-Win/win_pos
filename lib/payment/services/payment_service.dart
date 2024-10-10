import 'package:win_pos/payment/repository/payments_repository.dart';

class PaymentService {
  PaymentsRepository paymentsRepository = PaymentsRepository();

  Future<List> getAll() async {
    return await paymentsRepository.getAll();
  }

  Future<List> getByName(String name) async {
    return await paymentsRepository.getByName(name);
  }

  Future<Map> insertPayment(String name, String description) async {
    //check name is not null
    if (name.isNotEmpty) {
      var data = await paymentsRepository.getByName(name);
      if (data.isEmpty) {
        var num = await paymentsRepository.insertPayment(name, description);
        return {"msg": num};
      } else {
        return {"msg": "duplicate"};
      }
    }
    return {"msg": "name_null"};
  }

  Future<Map> updatePayment(int id, String name, String description) async {
    //check name is not null
    if (name.isNotEmpty) {
      var data = await paymentsRepository.getByName(name);
      if (data.isEmpty || data[0]["id"] == id) {
        await paymentsRepository.updatePayment(id, name, description);
        return {"msg": "success"};
      } else {
        return {"msg": "duplicate"};
      }
    }
    return {"msg": "name_null"};
  }

  Future<void> deletePayment(int id) async {
    await paymentsRepository.deletePayment(id);
  }
}
