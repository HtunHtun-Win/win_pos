import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/category/controller/category_controller.dart';
import 'package:win_pos/category/models/category_model.dart';
import 'package:win_pos/category/screens/category_add_screen.dart';
import 'package:win_pos/category/screens/category_edit_screen.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});
  final CategoryController categoryController = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Category"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () => Get.to(() => CategoryAddScreen()),
              icon: const Icon(Icons.add))
        ],
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: categoryController.categories.length,
          itemBuilder: (context, index) {
            var category = categoryController.categories[index];
            if (category.id == 1) return Container();
            return listItem(category);
          },
        );
      }),
    );
  }

  Widget listItem(CategoryModel category) {
    return Column(
      children: [
        ListTile(
          title: Text(category.name.toString()),
          subtitle: Text(category.description.toString()),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    Get.to(() => CategoryEditScreen(category));
                  },
                  icon: const Icon(Icons.edit)),
              IconButton(
                  onPressed: () {
                    Get.defaultDialog(
                        title: "Delete!",
                        middleText: "Are you sure to delete!",
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              categoryController.deleteCategory(category.id!);
                              Get.back();
                            },
                            child: const Text("Ok"),
                          ),
                        ]);
                  },
                  icon: const Icon(Icons.delete)),
            ],
          ),
        ),
        const Divider()
      ],
    );
  }
}
