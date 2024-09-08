import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/contact/supplier/controller/supplier_controller.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import '../controller/purchase_controller.dart';

class PurchaseSaveScreen extends StatelessWidget {
  PurchaseSaveScreen({super.key});
  PurchaseController purchaseController = Get.find();
  UserController userController = Get.find();
  SupplierController supplierController = SupplierController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController netAmountController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  int supplierId = 1;
  int totalPrice = 0;

  @override
  Widget build(BuildContext context) {
    supplierController.getAll();
    netAmountController.text = purchaseController.totalAmount.toString();
    totalPrice = purchaseController.totalAmount.value;
    totalController.text = totalPrice.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Save Vouchers"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                onSave();
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              suppliersBox(),
              const SizedBox(height: 10),
              infoBox(controller: phoneController, text: "Phone"),
              const SizedBox(height: 10),
              infoBox(controller: addressController, line: 2, text: "Address"),
              const SizedBox(height: 10),
              infoBox(controller: netAmountController, text: "Net Price"),
              const SizedBox(height: 10),
              discountBox(),
              const SizedBox(height: 10),
              infoBox(controller: totalController, text: "Total Price"),
            ],
          ),
        ),
      ),
    );
  }

  void onSave() async {
    Map purchaseMap = {
      "supplier_id": supplierId,
      "user_id": userController.current_user["id"],
      "net_price": purchaseController.totalAmount.value,
      "discount": purchaseController.discount.value,
      "total_price": totalPrice,
      "payment_type_id": 1,
    };
    await purchaseController.addPurchase(purchaseMap, purchaseController.cart);
    purchaseController.cart.clear();
    purchaseController.getAllVouchers();
    purchaseController.getTotal();
    Get.back();
  }

  Widget suppliersBox() {
    return Obx(() {
      return DropdownMenu(
        width: 200,
        requestFocusOnTap: true,
        enableFilter: true,
        dropdownMenuEntries: supplierController.suppliers.map((customer) {
          return DropdownMenuEntry(value: customer, label: customer.name);
        }).toList(),
        onSelected: (supplier) {
          supplierId = supplier.id;
          phoneController.text = supplier.phone.toString();
          addressController.text = supplier.address.toString();
        },
      );
    });
  }

  Widget infoBox({controller, line, text}) {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controller,
        readOnly: true,
        maxLines: line,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          label: Text(text),
        ),
      ),
    );
  }

  Widget discountBox() {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: discountController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
            border: OutlineInputBorder(), label: Text("discount")),
        onChanged: (value) {
          if (value.isNotEmpty) {
            totalPrice =
                purchaseController.totalAmount.value - int.parse(value);
            purchaseController.discount.value = int.parse(value);
            totalController.text = totalPrice.toString();
          } else {
            totalPrice = purchaseController.totalAmount.value - 0;
            purchaseController.discount.value = 0;
            totalController.text = totalPrice.toString();
          }
        },
      ),
    );
  }
}
