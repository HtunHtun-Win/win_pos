import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:win_pos/contact/supplier/controller/supplier_controller.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import '../../core/functions/date_range_calc.dart';
import '../../payment/controller/payment_controller.dart';
import '../controller/purchase_controller.dart';

class PurchaseSaveScreen extends StatelessWidget {
  PurchaseSaveScreen({super.key});
  PurchaseController purchaseController = Get.find();
  UserController userController = Get.find();
  SupplierController supplierController = SupplierController();
  PaymentController paymentController = PaymentController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController netAmountController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  int supplierId = 1;
  int totalPrice = 0;
  int paymentId = 1;

  @override
  Widget build(BuildContext context) {
    supplierController.getAll();
    paymentController.getAll();
    netAmountController.text = purchaseController.totalAmount.toString();
    totalPrice = purchaseController.totalAmount.value;
    totalController.text = totalPrice.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Save Vouchers"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
              paymentBox(),
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
      "payment_type_id": paymentId,
    };
    await purchaseController.addPurchase(purchaseMap, purchaseController.cart);
    purchaseController.cart.clear();
    purchaseController.getAllVouchers(map: daterangeCalculate("today"));
    purchaseController.getTotal();
    Get.back();
  }

  Widget suppliersBox() {
    return Obx((){
      return DropdownSearch<String>(
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Customer",
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
        items: supplierController.suppliers.map((customer) => customer.name.toString()).toList(),
        onChanged: (value) {
          final supplier = supplierController.suppliers.firstWhere(
                (supplier) => supplier.name == value,
          );
          supplierId = supplier.id;
          phoneController.text = supplier.phone.toString();
          addressController.text = supplier.address.toString();
        },
        selectedItem: "DefaultCustomer", // Optional: Can be null if no initial selection is required
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Customer",
            ),
          ),
        ),
      );
    });
  }

  Widget paymentBox() {
    return Obx((){
      return DropdownSearch<String>(
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Payment Type",
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
        items: paymentController.payments.map((payment) => payment.name.toString()).toList(),
        onChanged: (value) {
          final payment = paymentController.payments.firstWhere(
                (payment) => payment.name == value,
          );
          paymentId = payment.id;
        },
        selectedItem: "Cash", // Optional: Can be null if no initial selection is required
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Payment Type",
            ),
          ),
        ),
      );
    });
  }

  Widget infoBox({controller, line, text}) {
    return SizedBox(
      width: double.infinity,
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
      width: double.infinity,
      child: TextField(
        controller: discountController,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
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
