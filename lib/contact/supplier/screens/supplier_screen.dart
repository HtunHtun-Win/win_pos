import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/contact/supplier/controller/supplier_controller.dart';
import 'package:win_pos/contact/supplier/model/supplier_model.dart';
import 'package:win_pos/contact/supplier/screens/supplier_add_screen.dart';
import 'package:win_pos/contact/supplier/screens/supplier_edit_screen.dart';

class SupplierScreen extends StatelessWidget {
  SupplierScreen({super.key});

  final SupplierController supplierController = Get.put(SupplierController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => ListView.builder(
            itemCount: supplierController.suppliers.length,
            itemBuilder: (context, index) {
              var supplier = supplierController.suppliers[index];
              if (supplier.id == 1) {
                return Container();
              }
              return listItem(context, supplier);
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => SupplierAddScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget listItem(context, SupplierModel supplier) {
    Color color = Theme.of(context).primaryColor;
    Color textColor = Colors.black;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(5, 5),
              blurRadius: 10,
            ),
          ]),
      child: ListTile(
        title: Text(
          supplier.name.toString(),
          style: TextStyle(color: textColor),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              supplier.phone.toString(),
              style: TextStyle(
                color: textColor,
              ),
            ),
            Text(
              supplier.address.toString(),
              style: TextStyle(
                color: textColor,
              ),
            ),
          ],
        ),
        trailing: supplier.id == 1
            ? const SizedBox()
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () {
                        Get.to(() => SupplierEditScreen(supplier));
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
                                  supplierController.delete(supplier.id!);
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
