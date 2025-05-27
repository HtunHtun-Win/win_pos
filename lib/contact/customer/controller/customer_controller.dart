import 'package:get/get.dart';
import 'package:win_pos/contact/customer/model/customer_model.dart';
import 'package:win_pos/contact/customer/service/customer_service.dart';

class CustomerController extends GetxController {
  CustomerService customerService = CustomerService();
  var customers = [].obs;

  //for pull to refresh
  var showCustomers = [].obs;
  var maxCount = 10;

  @override
  void onInit() async {
    super.onInit();
    await getAll();
  }

  Future<void> getAll() async {
    maxCount = 10; // Reset maxCount to initial value
    var datas = await customerService.getAll();
    customers.clear();
    for (var data in datas) {
      customers.add(CustomerModel.fromMap(data));
    }
    if (customers.isNotEmpty) {
      showCustomers.clear();
      maxCount = customers.length < maxCount ? customers.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showCustomers.add(customers[i]);
      }
    }
  }

  Future<void> searchByKeyWork(String keyWork) async {
    maxCount = 10; // Reset maxCount to initial value
    var datas = await customerService.searchByKeyWork(keyWork);
    customers.clear();
    for (var data in datas) {
      customers.add(CustomerModel.fromMap(data));
    }
    if (customers.isNotEmpty) {
      showCustomers.clear();
      maxCount = customers.length < maxCount ? customers.length : maxCount;
      for (int i = 0; i < maxCount; i++) {
        showCustomers.add(customers[i]);
      }
    }
  }

  Future<Map> getByName(String name) async {
    return await customerService.getByName(name);
  }

  Future<Map> insert(String name, String phone, String address) async {
    var map = await customerService.insert(name, phone, address);
    getAll();
    return map;
  }

  Future<Map> updateCustomer(
      int id, String name, String phone, String address) async {
    var map = await customerService.update(id, name, phone, address);
    getAll();
    return map;
  }

  Future<void> delete(int id) async {
    await customerService.delete(id);
  }

  void loadMore() {
    Future.delayed(const Duration(microseconds: 1000), () {
      int rmData = customers.length - maxCount;
      int nextCount = rmData >= 10 ? 10 : rmData;
      for (int i = maxCount; i < maxCount + nextCount; i++) {
        showCustomers.add(customers[i]);
      }
      maxCount += nextCount;
    });
  }
}
