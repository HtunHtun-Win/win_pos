import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jue_pos/category/controller/category_controller.dart';

class CategoryAddScreen extends StatelessWidget {
  CategoryAddScreen({super.key});
  CategoryController categoryController = Get.find();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Category"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            userInput("Name",nameController),
            SizedBox(height: 10,),
            userInput("Description",descController),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: (){
                  nameController.clear();
                  descController.clear();
                }, child: Text("Clear")),
                TextButton(onPressed: () async{
                  var msg = await categoryController.insertCategory(
                      nameController.text,
                      descController.text
                  );
                  if(msg["msg"]=='name_null'){
                    Get.snackbar(
                        "Empty name!",
                        "Name field can't be empty!",
                        colorText: Colors.white,
                        backgroundColor: Colors.black.withOpacity(.4)
                    );
                  }else if(msg["msg"]=='duplicate'){
                    Get.snackbar(
                        "Duplicate!",
                        "This category is already exists!",
                        colorText: Colors.white,
                        backgroundColor: Colors.black.withOpacity(.4)
                    );
                  } else{
                    Get.back();
                  }
                }, child: Text("Save"))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget userInput(text,controller){
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: text,
        border: OutlineInputBorder()
      ),
    );
  }
}
