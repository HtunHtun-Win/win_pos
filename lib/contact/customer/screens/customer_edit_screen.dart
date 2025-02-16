import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:win_pos/contact/customer/controller/customer_controller.dart';
import 'package:win_pos/contact/customer/model/customer_model.dart';

class CustomerEditScreen extends StatelessWidget {
  CustomerModel customer;
  CustomerEditScreen(this.customer, {super.key});
  CustomerController customerController = Get.find();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nameController.text = customer.name!;
    phoneController.text = customer.phone!;
    addressController.text = customer.address!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Customer'),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                update(customer.id!, nameController.text, phoneController.text,
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
    var msg = await customerController.updateCustomer(id, name, phone, address);
    if (msg["msg"] == "name_null") {
      Get.snackbar("Name empty!", "Name can't be empty!");
    } else if (msg["msg"] == "duplicate") {
      Get.snackbar("Duplicate!", "This customer is already exists!");
    } else {
      Get.back();
    }
  }
}
