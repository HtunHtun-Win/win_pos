import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/contact/supplier/controller/supplier_controller.dart';

class SupplierAddScreen extends StatelessWidget {
  SupplierAddScreen({super.key});
  final SupplierController supplierController = Get.find();

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Supplier'),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                save(nameController.text, phoneController.text,
                    addressController.text);
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            userInput("Name", nameController),
            userInput("Phone", phoneController, type: TextInputType.number),
            userInput("Address", addressController, maxlines: 2),
          ],
        ),
      ),
    );
  }

  Widget userInput(text, controller, {maxlines, type}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: maxlines,
        decoration: InputDecoration(
            label: Text(text), border: const OutlineInputBorder()),
      ),
    );
  }

  Future<void> save(String name, String phone, String address) async {
    var msg = await supplierController.insert(name, phone, address);
    if (msg["msg"] == "name_null") {
      Get.dialog(
          AlertDialog(
            title: const Text("Name empty!!"),
            content: const Text("Name can't be empty!"),
            actions: [
              TextButton(onPressed: (){Get.back();}, child: const Text("OK"))
            ],
          )
      );
    } else if (msg["msg"] == "duplicate") {
      Get.dialog(
          AlertDialog(
            title: const Text("Duplicate!"),
            content: const Text("This Supplier is already exists!"),
            actions: [
              TextButton(onPressed: (){Get.back();}, child: const Text("OK"))
            ],
          )
      );
    } else {
      Get.back();
    }
  }
}
