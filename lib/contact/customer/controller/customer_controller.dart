import 'package:get/get.dart';
import 'package:jue_pos/contact/customer/model/customer_model.dart';
import 'package:jue_pos/contact/customer/service/customer_service.dart';

class CustomerController extends GetxController{
  CustomerService customerService = CustomerService();
  var customers = [].obs;

  @override
  void onInit() {
    super.onInit();
    getAll();
  }

  Future<void> getAll() async{
    var datas = await customerService.getAll();
    customers.clear();
    datas.forEach((data){
      customers.add(
        CustomerModel.fromMap(data)
      );
    });
  }

  Future<Map> getByName(String name) async{
    return await customerService.getByName(name);
  }

  Future<Map> insert(String name, String phone, String address) async{
    var map =  await customerService.insert(name, phone, address);
    getAll();
    return map;
  }

  Future<Map> updateCustomer(int id,String name, String phone, String address) async{
    var map = await customerService.update(id, name, phone, address);
    getAll();
    return map;
  }

  Future<void> delete(int id) async{
    await customerService.delete(id);
    getAll();
  }
}