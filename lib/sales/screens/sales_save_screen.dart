import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:win_pos/contact/customer/controller/customer_controller.dart';
import 'package:win_pos/sales/models/sale_model.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import '../controller/sales_controller.dart';

class SalesSaveScreen extends StatelessWidget {
  SalesSaveScreen({super.key});
  SalesController salesController = Get.find();
  UserController userController = Get.find();
  CustomerController customerController = CustomerController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController netAmountController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  int customerId = 1;
  int totalPrice = 0;

  @override
  Widget build(BuildContext context) {
    customerController.getAll();
    netAmountController.text = salesController.totalAmount.toString();
    totalPrice = salesController.totalAmount.value;
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
              customersBox(),
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
    Map saleMap = {
      "customer_id": customerId,
      "user_id": userController.current_user["id"],
      "net_price": salesController.totalAmount.value,
      "discount": salesController.discount.value,
      "total_price": totalPrice,
      "payment_type_id": 1,
    };
    await salesController.addSale(saleMap, salesController.cart);
    salesController.cart.clear();
    salesController.getAllVouchers();
    salesController.getTotal();
    Get.back();
  }

  Widget customersBox() {
    return Obx((){
      return DropdownSearch<String>(
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Customer",
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
        items: customerController.customers.map((customer) => customer.name.toString()).toList(),
        onChanged: (value) {
          final customer = customerController.customers.firstWhere(
                (customer) => customer.name == value,
          );
          customerId = customer.id;
          phoneController.text = customer.phone.toString();
          addressController.text = customer.address.toString();
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

  // Widget customersBox() {
  //   return Obx(() {
  //     return DropdownMenu(
  //       label: const Text("Customer"),
  //       width: double.infinity,
  //       requestFocusOnTap: true,
  //       enableFilter: true,
  //       enableSearch: true,
  //       dropdownMenuEntries: customerController.customers.map((customer) {
  //         return DropdownMenuEntry(value: customer, label: customer.name);
  //       }).toList(),
  //       onSelected: (customer) {
  //         customerId = customer.id;
  //         phoneController.text = customer.phone.toString();
  //         addressController.text = customer.address.toString();
  //       },
  //     );
  //   });
  // }

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
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
            border: OutlineInputBorder(), label: Text("discount")),
        onChanged: (value) {
          if (value.isNotEmpty) {
            totalPrice = salesController.totalAmount.value - int.parse(value);
            salesController.discount.value = int.parse(value);
            totalController.text = totalPrice.toString();
          } else {
            totalPrice = salesController.totalAmount.value - 0;
            salesController.discount.value = 0;
            totalController.text = totalPrice.toString();
          }
        },
      ),
    );
  }
}
