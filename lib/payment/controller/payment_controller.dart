import 'package:get/get.dart';
import 'package:win_pos/payment/models/payment_model.dart';
import 'package:win_pos/payment/services/payment_service.dart';

class PaymentController extends GetxController {
  var payments = [].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getAll();
  }

  PaymentService paymentService = PaymentService();

  void getAll() async {
    var datas = await paymentService.getAll();
    payments.clear();
    for (var data in datas) {
      payments.add(PaymentModel.fromJson(data));
    }
  }

  Future<List> getByName(String name) async {
    return await paymentService.getByName(name);
  }

  Future<Map> insertPayment(String name, String description) async {
    var num = await paymentService.insertPayment(name, description);
    getAll();
    return num;
  }

  Future<Map> updatePayment(int id, String name, String description) async {
    var data = await paymentService.updatePayment(id, name, description);
    getAll();
    return data;
  }

  Future<void> deletePayment(int id) async {
    await paymentService.deletePayment(id);
    getAll();
  }
}
