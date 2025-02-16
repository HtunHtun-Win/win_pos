import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/category/controller/category_controller.dart';
import 'package:win_pos/payment/controller/payment_controller.dart';
import 'package:win_pos/payment/models/payment_model.dart';

class PaymentEditScreen extends StatelessWidget {
  PaymentModel payment;
  PaymentEditScreen(this.payment, {super.key});

  PaymentController paymentController = Get.find();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nameController.text = payment.name;
    descController.text = payment.description;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Category"),
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
                      var msg = await paymentController.updatePayment(
                          payment.id,
                          nameController.text,
                          descController.text);
                      if (msg["msg"] == 'name_null') {
                        Get.snackbar(
                            "Empty name!", "Name field can't be empty!",
                            colorText: Colors.white,
                            backgroundColor: Colors.black.withOpacity(.4));
                      } else if (msg["msg"] == 'duplicate') {
                        Get.snackbar(
                            "Duplicate!", "This category is already exists!",
                            colorText: Colors.white,
                            backgroundColor: Colors.black.withOpacity(.4));
                      } else {
                        Get.back();
                      }
                    },
                    child: const Text("Update"))
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
