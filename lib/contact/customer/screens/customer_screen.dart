import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/contact/customer/controller/customer_controller.dart';
import 'package:win_pos/contact/customer/model/customer_model.dart';
import 'package:win_pos/contact/customer/screens/customer_add_screen.dart';

import 'customer_edit_screen.dart';

class CustomerScreen extends StatelessWidget {
  CustomerScreen({super.key});
  CustomerController customerController = Get.put(CustomerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => ListView.builder(
            itemCount: customerController.customers.length,
            itemBuilder: (context, index) {
              var customer = customerController.customers[index];
              if (customer.id == 1) {
                return Container();
              }
              return listItem(context, customer);
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => CustomerAddScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget listItem(context, CustomerModel customer) {
    Color color = Colors.white;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          customer.name.toString(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              customer.phone.toString(),
              style: TextStyle(
                color: color,
              ),
            ),
            Text(
              customer.address.toString(),
              style: TextStyle(
                color: color,
              ),
            ),
          ],
        ),
        trailing: customer.id == 1
            ? const SizedBox()
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () {
                        Get.to(() => CustomerEditScreen(customer));
                      },
                      icon: Icon(
                        Icons.edit,
                        color: color,
                      )),
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
                                  customerController.delete(customer.id!);
                                  Get.back();
                                },
                                child: const Text("Ok"),
                              ),
                            ]);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: color,
                      )),
                ],
              ),
      ),
    );
  }
}
