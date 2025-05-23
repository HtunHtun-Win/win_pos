import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:win_pos/product/controller/product_log_controller.dart';
import 'package:win_pos/user/controllers/user_controller.dart';

// ignore: must_be_immutable
class ProductAdjustAddScreen extends StatelessWidget {
  ProductAdjustAddScreen({super.key});
  ProductLogController productLogController = Get.find();
  TextEditingController qtyController = TextEditingController();
  UserController userController = Get.find();
  int? pId;
  int? currentQty;
  int newQty = 0;
  String type = 'adjust';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        productLogController.clearSelected();
        Get.back();
      },
      child: Scaffold(
          appBar: AppBar(
            // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text("Product Adjustment"),
            actions: [
              IconButton(
                  onPressed: () async {
                    if (type == 'lose') {
                      qtyController.text = '-${qtyController.text}';
                    }
                    await productLogController.addProductLog(
                        pId!,
                        int.parse(qtyController.text),
                        type,
                        userController.current_user['id'],
                    );
                    Get.back();
                  },
                  icon: const Icon(Icons.save))
            ],
          ),
          body: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                productList(),
                const SizedBox(
                  height: 10,
                ),
                typeChange(),
                const SizedBox(
                  height: 20,
                ),
                Obx(() {
                  return selectedQtyRow();
                }),
              ],
            ),
          )),
    );
  }

  Widget selectedQtyRow(){
    return SizedBox(
      width: 350,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 50),
          Column(
            children: [
              const Text("Current"),
              Text(
                productLogController.selectedProduct['qty']
                    .toString(),
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
              child: TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                    label: Text("Adust quantity"),
                    border: OutlineInputBorder()),
                onChanged: (value) {
                  value = value.isNotEmpty ? value : '0';
                  if (type == 'lose') value = '-$value';
                  newQty =
                      productLogController.selectedProduct['qty']! +
                          int.parse(value);
                  productLogController.selectedProduct['pid'] = pId!;
                },
              )),
          const SizedBox(width: 10),
          Column(
            children: [
              const Text("New"),
              Text(
                newQty.toString(),
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget typeChange() {
    return DropdownMenu(
      initialSelection: "adjust",
      width: double.infinity,
      dropdownMenuEntries: const [
        DropdownMenuEntry(value: "adjust", label: "Adjust"),
        DropdownMenuEntry(value: "lose", label: "Lose"),
      ],
      onSelected: (value) {
        type = value!;
      },
    );
  }

  Widget productList() {
    return DropdownSearch<String>(
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Select Item...",
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          border: OutlineInputBorder(),
        ),
      ),
      items: productLogController.products.map((product) => product.name.toString()).toList(),
      onChanged: (value) {
        final item = productLogController.products.firstWhere(
              (product) => product.name == value,
        );
        pId = item.id;
        currentQty = item.quantity;
        productLogController.selectedProduct['pid'] = pId!;
        productLogController.selectedProduct['qty'] = currentQty!;
      },
      selectedItem: null, // Optional: Can be null if no initial selection is required
      popupProps: const PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Select Item",
          ),
        ),
      ),
    );
  }

  // Widget productList() {
  //   return DropdownMenu(
  //     enableFilter: true,
  //     requestFocusOnTap: true,
  //     hintText: "Search...",
  //     width: 350,
  //     dropdownMenuEntries: productLogController.products.value.map((product) {
  //       return DropdownMenuEntry(
  //           value: product, label: "${product.name} (${product.quantity} pcs)");
  //     }).toList(),
  //     onSelected: (value) {
  //       pId = value.id;
  //       currentQty = value.quantity;
  //       productLogController.selectedProduct['pid'] = pId!;
  //       productLogController.selectedProduct['qty'] = currentQty!;
  //     },
  //   );
  // }

}
