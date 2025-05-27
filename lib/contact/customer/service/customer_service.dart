import 'package:win_pos/contact/customer/repository/customer_repository.dart';

class CustomerService {
  CustomerRepository customerRepository = CustomerRepository();

  Future<List> getAll() async {
    return await customerRepository.getAll();
  }

  Future<List> searchByKeyWork(String keyWork) async {
    return await customerRepository.searchByKeyWork(keyWork);
  }

  Future<Map> getByName(String name) async {
    var datas = await customerRepository.getByName(name);
    if (datas.isNotEmpty) {
      return datas[0];
    }
    return {};
  }

  Future<Map> insert(String name, String phone, String address) async {
    if (name.isNotEmpty) {
      var map = await getByName(name);
      if (map.isNotEmpty) {
        return {"msg": "duplicate"};
      } else {
        var num = await customerRepository.insert(name, phone, address);
        return {"msg": num};
      }
    }
    return {"msg": "name_null"};
  }

  Future<Map> update(int id, String name, String phone, String address) async {
    if (name.isNotEmpty) {
      var map = await getByName(name);
      if (map.isNotEmpty) {
        if (map["id"] == id) {
          var num = await customerRepository.update(id, name, phone, address);
          return {"msg": num};
        }
        return {"msg": "duplicate"};
      } else {
        var num = await customerRepository.update(id, name, phone, address);
        return {"msg": num};
      }
    }
    return {"msg": "name_null"};
  }

  Future<void> delete(int id) async {
    await customerRepository.delete(id);
  }
}
