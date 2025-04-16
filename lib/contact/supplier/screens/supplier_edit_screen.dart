import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/contact/supplier/controller/supplier_controller.dart';
import 'package:win_pos/contact/supplier/model/supplier_model.dart';

class SupplierEditScreen extends StatelessWidget {
  SupplierModel supplier;
  SupplierEditScreen(this.supplier, {super.key});
  SupplierController supplierController = Get.find();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nameController.text = supplier.name!;
    phoneController.text = supplier.phone!;
    addressController.text = supplier.address!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Supplier'),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                update(supplier.id!, nameController.text, phoneController.text,
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

  Future<void> update(int id, String name, String phone, String address) async {
    var msg = await supplierController.updateCustomer(id, name, phone, address);
    if (msg["msg"] == "name_null") {
      Get.snackbar("Name empty!", "Name can't be empty!");
    } else if (msg["msg"] == "duplicate") {
      Get.snackbar("Duplicate!", "This customer is already exists!");
    } else {
      Get.back();
    }
  }
}
