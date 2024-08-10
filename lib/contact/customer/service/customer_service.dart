import 'package:jue_pos/contact/customer/repository/customer_repository.dart';

class CustomerService{
  CustomerRepository customerRepository = CustomerRepository();

  Future<List> getAll() async{
    return await customerRepository.getAll();
  }

  Future<Map> getByName(String name) async{
    return await customerRepository.getByName(name);
  }

  Future<int> insert(String name, String phone, String address) async{
    return await customerRepository.insert(name, phone, address);
  }

  Future<int> update(int id,String name, String phone, String address) async{
    return await customerRepository.update(id, name, phone, address);
  }

  Future<void> delete(int id) async{
    await customerRepository.delete(id);
  }
}