import 'package:jue_pos/category/repository/category_repository.dart';

class CategoryService{
  CategoryRepository categoryRepository = CategoryRepository();

  Future<List> getAll() async{
    return await categoryRepository.getAll();
  }

  Future<List> getByName(String name) async{
    return await categoryRepository.getByName(name);
  }

  Future<Map> insertCategory(String name,String description) async{
    //check name is not null
    if(name.length>0){
      var data = await categoryRepository.getByName(name);
      if(data.isEmpty){
        var num = await categoryRepository.insertCategory(name, description);
        return {"msg":num};
      }else{
        return {"msg":"duplicate"};
      }
    }
    return {"msg":"name_null"};
  }

  Future<Map> updateCategory(int id,String name,String description) async{
    //check name is not null
    if(name.length>0){
      var data = await categoryRepository.getByName(name);
      if( data.isEmpty || data[0]["id"]==id){
        await categoryRepository.updateCategory(id, name, description);
        return {"msg":"success"};
      }else{
        return {"msg":"duplicate"};
      }
    }
    return {"msg":"name_null"};
  }

  Future<void> deleteCategory(int id) async{
    await categoryRepository.deleteCategory(id);
  }

}