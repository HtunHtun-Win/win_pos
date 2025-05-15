import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/payment/controller/payment_controller.dart';
import 'package:win_pos/payment/models/payment_model.dart';
import 'package:win_pos/payment/screens/payment_add_screen.dart';
import 'package:win_pos/payment/screens/payment_edit_screen.dart';

class PaymentScreen extends StatelessWidget {
  PaymentScreen({super.key});
  final PaymentController paymentController = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payments"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () => Get.to(() => PaymentAddScreen()),
              icon: const Icon(Icons.add))
        ],
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: paymentController.payments.length,
          itemBuilder: (context, index) {
            var category = paymentController.payments[index];
            if (category.id == 1) return Container();
            return listItem(category);
          },
        );
      }),
    );
  }

  Widget listItem(PaymentModel payment) {
    return Column(
      children: [
        ListTile(
          title: Text(payment.name.toString()),
          subtitle: Text(payment.description.toString()),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    Get.to(() => PaymentEditScreen(payment));
                  },
                  icon: const Icon(Icons.edit)),
              IconButton(
                  onPressed: () {
                    Get.defaultDialog(
                        title: "Delete!",
                        middleText: "Are you sure to delete!",
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              paymentController.deletePayment(payment.id);
                              Get.back();
                            },
                            child: const Text("Ok"),
                          ),
                        ]);
                  },
                  icon: const Icon(Icons.delete)),
            ],
          ),
        ),
        const Divider()
      ],
    );
  }
}
