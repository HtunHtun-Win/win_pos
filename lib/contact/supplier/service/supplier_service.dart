import 'package:win_pos/contact/supplier/repository/supplier_repository.dart';

class SupplierService {
  SupplierRepository supplierRepository = SupplierRepository();

  Future<List> getAll() async {
    return await supplierRepository.getAll();
  }

  Future<List> searchByKeyWork(String keyWork) async {
    return await supplierRepository.searchByKeyWork(keyWork);
  }

  Future<Map> getByName(String name) async {
    var datas = await supplierRepository.getByName(name);
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
        var num = await supplierRepository.insert(name, phone, address);
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
          var num = await supplierRepository.update(id, name, phone, address);
          return {"msg": num};
        }
        return {"msg": "duplicate"};
      } else {
        var num = await supplierRepository.update(id, name, phone, address);
        return {"msg": num};
      }
    }
    return {"msg": "name_null"};
  }

  Future<void> delete(int id) async {
    await supplierRepository.delete(id);
  }
}
