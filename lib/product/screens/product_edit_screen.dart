import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/category/controller/category_controller.dart';
import 'package:win_pos/category/models/category_model.dart';
import 'package:win_pos/product/controller/product_controller.dart';
import 'package:win_pos/product/models/product_model.dart';

class ProductEditScreen extends StatelessWidget {
  ProductEditScreen(this.productModel, {super.key});
  ProductModel productModel;
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
    nameController.text = productModel.name!;
    codeController.text = productModel.code!;
    descController.text = productModel.description!;
    quantityController.text = productModel.quantity.toString();
    ppriceController.text = productModel.purchase_price.toString();
    spriceController.text = productModel.sale_price.toString();
    category_id = productModel.category_id!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                updateProduct(
                  productModel.id!,
                  codeController.text,
                  nameController.text,
                  descController.text,
                  category_id, 
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
            const SizedBox(width: 8),
            categoryBox(context),
            const SizedBox(width: 8),
            userInput("Name", nameController),
            userInput("Code", codeController),
            userInput("Description", descController, num: 2),
            userInput("Quantity", quantityController,type: TextInputType.number,state: true),
            Row(
              children: [
                Expanded(
                    child: userInput("Purchase Price", ppriceController,
                        type: TextInputType.number, state: true)),
                const SizedBox(width: 10,),
                Expanded(
                    child: userInput("Sale Price", spriceController,
                        type: TextInputType.number, state: false)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> updateProduct(int id, String code, String name,
      String description, int categoryId, int salePrice) async {
    var map = await productController.updateProduct(
        id, code, name, description, categoryId, salePrice);
    if (map["msg"] == "null") {
      Get.snackbar("Empty!", "Name and code can't be empty...");
    } else if (map["msg"] == "duplicate") {
      Get.snackbar("Duplicate!", "This code is already exist...");
    } else {
      Get.back();
    }
  }

  Widget userInput(text, controller, {type, num, state}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: num,
        readOnly: state ?? false,
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
      selectedItem: "Select Category", // Optional: Can be null if no initial selection is required
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

}
