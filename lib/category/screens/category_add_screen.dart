import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/category/controller/category_controller.dart';

// ignore: must_be_immutable
class CategoryAddScreen extends StatelessWidget {
  CategoryAddScreen({super.key});
  CategoryController categoryController = Get.find();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Category"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            userInput("Name", nameController),
            const SizedBox(
              height: 10,
            ),
            userInput("Description", descController),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      nameController.clear();
                      descController.clear();
                    },
                    child: const Text("Clear")),
                TextButton(
                    onPressed: () async {
                      var msg = await categoryController.insertCategory(
                          nameController.text, descController.text);
                      if (msg["msg"] == 'name_null') {
                        Get.snackbar(
                            "Empty name!", "Name field can't be empty!",
                            colorText: Colors.white,
                            backgroundColor: Colors.black.withValues(alpha: .4));
                      } else if (msg["msg"] == 'duplicate') {
                        Get.snackbar(
                            "Duplicate!", "This category is already exists!",
                            colorText: Colors.white,
                            backgroundColor: Colors.black.withValues(alpha: .4));
                      } else {
                        Get.back();
                      }
                    },
                    child: const Text("Save"))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget userInput(text, controller) {
    return TextField(
      controller: controller,
      decoration:
          InputDecoration(hintText: text, border: const OutlineInputBorder()),
    );
  }
}
