import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/category/controller/category_controller.dart';
import 'package:win_pos/category/models/category_model.dart';
import 'package:win_pos/product/controller/product_controller.dart';

class ProductAddScreen extends StatelessWidget {
  ProductAddScreen({super.key});
  ProductController productController = Get.find();
  CategoryController categoryController = Get.find();
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController ppriceController = TextEditingController();
  TextEditingController spriceController = TextEditingController();
  int category_id = 1;

  @override
  Widget build(BuildContext context) {
    quantityController.text = 0.toString();
    ppriceController.text = 0.toString();
    spriceController.text = 0.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Product"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                addProduct(
                  codeController.text,
                  nameController.text,
                  descController.text,
                  int.parse(quantityController.text),
                  category_id,
                  int.parse(ppriceController.text),
                  int.parse(spriceController.text),
                );
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: ListView(
          children: [
            userInput("Name", nameController),
            userInput("Code", codeController),
            userInput("Description", descController, num: 2),
            Row(
              children: [
                Expanded(
                    child: userInput("Quantity", quantityController,
                        type: TextInputType.number)),
                const SizedBox(
                  width: 10,
                ),
                categoryBox(context),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: userInput("Purchase Price", ppriceController,
                        type: TextInputType.number)),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: userInput("Sale Price", spriceController,
                        type: TextInputType.number)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> addProduct(String code, String name, String description,
      int quantity, int categoryId, int purchasePrice, int salePrice) async {
    var map = await productController.addProduct(code, name, description,
        quantity, categoryId, purchasePrice, salePrice);
    if (map["msg"] == "null") {
      Get.snackbar("Empty!", "Name, code and purchase price can't be empty...");
    } else if (map["msg"] == "duplicate") {
      Get.snackbar("Duplicate!", "This code is already exist...");
    } else {
      Get.back();
    }
  }

  Widget userInput(text, controller, {type, num}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: num,
        decoration: InputDecoration(
            labelText: text, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget categoryBox(context) {
    return DropdownMenu(
      label: const Text("Category"),
      enableFilter: true,
      requestFocusOnTap: true,
      width: 180,
      dropdownMenuEntries: categoryController.categories.map((category) {
        return DropdownMenuEntry(value: category.id, label: category.name);
      }).toList(),
      onSelected: (value) {
        category_id = value;
      },
    );
  }
}
