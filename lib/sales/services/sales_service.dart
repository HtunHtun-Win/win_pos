import 'package:win_pos/sales/repository/sales_repository.dart';

class SalesService{
  SalesRepository salesRepository = SalesRepository();

  Future<List> getAllProduct({String? input}) async{
    if(input!.length>0){
      return await salesRepository.getByFilter(input);
    }
    return [];
  }

  Future<List> getById(int id) async{
    return await salesRepository.getById(id);
  }

}