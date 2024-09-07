import 'package:get/get.dart';
import 'package:win_pos/contact/customer/model/customer_model.dart';
import 'package:win_pos/contact/supplier/model/supplier_model.dart';
import 'package:win_pos/contact/supplier/service/supplier_service.dart';

class SupplierController extends GetxController {
  SupplierService supplierService = SupplierService();
  var suppliers = [].obs;

  @override
  void onInit() {
    super.onInit();
    getAll();
  }

  Future<void> getAll() async {
    var datas = await supplierService.getAll();
    suppliers.clear();
    for (var data in datas) {
      suppliers.add(SupplierModel.fromMap(data));
    }
  }

  Future<Map> getByName(String name) async {
    return await supplierService.getByName(name);
  }

  Future<Map> insert(String name, String phone, String address) async {
    var map = await supplierService.insert(name, phone, address);
    getAll();
    return map;
  }

  Future<Map> updateCustomer(
      int id, String name, String phone, String address) async {
    var map = await supplierService.update(id, name, phone, address);
    getAll();
    return map;
  }

  Future<void> delete(int id) async {
    await supplierService.delete(id);
    getAll();
  }
}
