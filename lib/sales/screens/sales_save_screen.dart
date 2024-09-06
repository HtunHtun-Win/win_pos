import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:win_pos/contact/customer/controller/customer_controller.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import '../controller/sales_controller.dart';

class SalesSaveScreen extends StatelessWidget {
  SalesSaveScreen({super.key});
  SalesController salesController = Get.find();
  CustomerController customerController = CustomerController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController netAmountController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  int customerId = 0;
  int totalPrice = 0;

  @override
  Widget build(BuildContext context) {
    UserController userController = Get.find();
    customerController.getAll();
    netAmountController.text = salesController.totalAmount.toString();
    totalPrice = salesController.totalAmount.value;
    totalController.text = totalPrice.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text("Save Vouchers"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                onSave();
              },
              icon: Icon(Icons.save)
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            customersBox(),
            SizedBox(height: 10,),
            infoBox(controller: phoneController,text: "Phone"),
            SizedBox(height: 10,),
            infoBox(controller: addressController,line: 2,text: "Address"),
            SizedBox(height: 10,),
            infoBox(controller: netAmountController,text: "Net Price"),
            SizedBox(height: 10,),
            discountBox(),
            SizedBox(height: 10,),
            infoBox(controller: totalController,text: "Total Price"),
          ],
        ),
      ),
    );
  }

  void onSave() async{

  }

  Widget customersBox(){
    return Obx((){
      return DropdownMenu(
      width: 200,
      requestFocusOnTap: true,
      enableFilter: true,
      dropdownMenuEntries:
      customerController.customers.map((customer){
          return DropdownMenuEntry(
              value: customer,
              label: customer.name
          );
        }).toList(),
      onSelected: (customer){
        customerId = customer.id;
        phoneController.text = customer.phone.toString();
        addressController.text = customer.address.toString();
      },
    );
    });
  }

  Widget infoBox({controller,line,text}){
    return Container(
      width: 200,
      child: TextField(
        controller: controller,
        readOnly: true,
        maxLines: line,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          label: Text(text)
        ),
      ),
    );
  }

  Widget discountBox(){
    return Container(
      width: 200,
      child: TextField(
        controller: discountController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          label: Text("discount")
        ),
        onChanged: (value){
          if(value.length>0){
            totalPrice = int.parse(netAmountController.text) - int.parse(value);
            totalController.text = totalPrice.toString();
          }else{
            totalPrice = int.parse(netAmountController.text) - 0;
            totalController.text = totalPrice.toString();
          }
        },
      ),
    );
  }
}
