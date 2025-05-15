import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:win_pos/category/controller/category_controller.dart';
import 'package:win_pos/product/controller/product_controller.dart';
import 'package:dropdown_search/dropdown_search.dart';

// ignore: must_be_immutable
class ProductAddScreen extends StatelessWidget {
  ProductAddScreen({super.key});
  final ProductController productController = Get.find();
  final CategoryController categoryController = Get.find();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController ppriceController = TextEditingController();
  final TextEditingController spriceController = TextEditingController();
  int category_id = 1;

  @override
  Widget build(BuildContext context) {
    quantityController.text = 0.toString();
    ppriceController.text = 0.toString();
    spriceController.text = 0.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Product"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            const SizedBox(height: 8),
            categoryBox(context),
            const SizedBox(height: 8),
            userInput("Name", nameController),
            userInput("Code", codeController),
            userInput("Description", descController, num: 2),
            userInput(
                "Quantity",
                quantityController,
                type: TextInputType.number,
              filter: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ]
            ),
            Row(
              children: [
                Expanded(
                    child: userInput(
                        "Purchase Price", ppriceController,
                        type: TextInputType.number,
                        filter: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ]
                    )),
                const SizedBox(width: 10),
                Expanded(
                    child: userInput(
                        "Sale Price", spriceController,
                        type: TextInputType.number,
                        filter: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ]
                    )),
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

  Widget userInput(text, controller, {type, num,filter}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: num,
        inputFormatters: filter,
        decoration: InputDecoration(
            labelText: text, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget categoryBox(BuildContext context) {
    return DropdownSearch<String>(
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Category",
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          border: OutlineInputBorder(),
        ),
      ),
      items: categoryController.categories.map((category) => category.name.toString()).toList(),
      onChanged: (String? selectedCategory) {
        final selected = categoryController.categories.firstWhere(
              (category) => category.name == selectedCategory,
        );
        category_id = selected.id;
      },
      selectedItem: "Default Category", // Optional: Can be null if no initial selection is required
      popupProps: const PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Search Category",
          ),
        ),
      ),
    );
  }

  // Widget categoryBox(context) {
  //   return DropdownMenu(
  //     label: const Text("Category"),
  //     enableFilter: true,
  //     requestFocusOnTap: true,
  //     width: double.infinity,
  //     dropdownMenuEntries: categoryController.categories.map((category) {
  //       return DropdownMenuEntry(value: category.id, label: category.name);
  //     }).toList(),
  //     onSelected: (value) {
  //       category_id = value;
  //     },
  //   );
  // }
}
