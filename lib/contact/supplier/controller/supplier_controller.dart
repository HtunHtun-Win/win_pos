import 'package:get/get.dart';
import 'package:win_pos/contact/supplier/model/supplier_model.dart';
import 'package:win_pos/contact/supplier/service/supplier_service.dart';

class SupplierController extends GetxController {
  SupplierService supplierService = SupplierService();
  var suppliers = [].obs;

  //for pull to refresh
  var showSuppliers = [].obs;
  var maxCount = 10;

  @override
  void onInit() {
    super.onInit();
    getAll();
  }

  Future<void> getAll() async {
    maxCount = 10; // reset maxCount for new fetch
    var datas = await supplierService.getAll();
    suppliers.clear();
    for (var data in datas) {
      suppliers.add(SupplierModel.fromMap(data));
    }
    if (suppliers.isNotEmpty) {
      showSuppliers.clear();
      maxCount = suppliers.length < maxCount ? suppliers.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showSuppliers.add(suppliers[i]);
      }
    }
  }

  Future<void> searchByKeyWork(String keyWork) async {
    maxCount = 10; // reset maxCount for new fetch
    var datas = await supplierService.searchByKeyWork(keyWork);
    suppliers.clear();
    for (var data in datas) {
      suppliers.add(SupplierModel.fromMap(data));
    }
    if (suppliers.isNotEmpty) {
      showSuppliers.clear();
      maxCount = suppliers.length < maxCount ? suppliers.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showSuppliers.add(suppliers[i]);
      }
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
  }

  void loadMore() {
    Future.delayed(const Duration(microseconds: 1000), () {
      int rmData = suppliers.length - maxCount;
      int nextCount = rmData >= 10 ? 10 : rmData;
      for (int i = maxCount; i < maxCount + nextCount; i++) {
        showSuppliers.add(suppliers[i]);
      }
      maxCount += nextCount;
    });
  }
}
