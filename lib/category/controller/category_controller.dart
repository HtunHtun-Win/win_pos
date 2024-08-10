import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jue_pos/category/services/category_service.dart';
import 'package:jue_pos/category/models/category_model.dart';

class CategoryController extends GetxController{

  var categories = [].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getAll();
  }

  CategoryService categoryService = CategoryService();

  void getAll() async{
    var datas = await categoryService.getAll();
    categories.clear();
    datas.forEach((data){
      categories.add(CategoryModel.fromMap(data));
    });
  }

  Future<List> getByName(String name) async{
    return await categoryService.getByName(name);
  }

  Future<Map> insertCategory(String name,String description) async{
    var num = await categoryService.insertCategory(name, description);
    getAll();
    return num;
  }

  Future<Map> updateCategory(int id,String name,String description) async{
    var data = await categoryService.updateCategory(id, name, description);
    getAll();
    return data;
  }

  Future<void> deleteCategory(int id) async{
    await categoryService.deleteCategory(id);
    getAll();
  }

}