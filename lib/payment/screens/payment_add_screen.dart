import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/payment_controller.dart';

class PaymentAddScreen extends StatelessWidget {
  PaymentAddScreen({super.key});
  final PaymentController paymentController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Payment"),
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
                      var msg = await paymentController.insertPayment(
                          nameController.text, descController.text);
                      if (msg["msg"] == 'name_null') {
                        Get.snackbar(
                            "Empty name!", "Name field can't be empty!",
                            colorText: Colors.white,
                            backgroundColor: Colors.black.withValues(alpha: .4));
                      } else if (msg["msg"] == 'duplicate') {
                        Get.snackbar(
                            "Duplicate!", "This payment type is already exists!",
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
