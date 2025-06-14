import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/contact/customer/controller/customer_controller.dart';

class CustomerAddScreen extends StatelessWidget {
  CustomerAddScreen({super.key});

  final CustomerController customerController = Get.find();

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Customer'),
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
    var msg = await customerController.insert(name, phone, address);
    if (msg["msg"] == "name_null") {
      Get.snackbar(
        "Name empty!",
        "Name can't be empty!",
        backgroundColor: Colors.black45,
        colorText: Colors.white,
      );
    } else if (msg["msg"] == "duplicate") {
      Get.snackbar(
        "Duplicate!",
        "This customer is already exists!",
        backgroundColor: Colors.black45,
        colorText: Colors.white,
      );
    } else {
      Get.back();
    }
  }
}
