import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jue_pos/contact/customer/controller/customer_controller.dart';
import 'package:jue_pos/contact/customer/model/customer_model.dart';

class CustomerScreen extends StatelessWidget {
  CustomerScreen({super.key});
  CustomerController customerController = Get.put(CustomerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=>ListView.builder(
        itemCount: customerController.customers.length,
        itemBuilder: (context,index){
          var customer = customerController.customers[index];
          return listItem(context,customer);
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          print("Go to add screen");
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget listItem(context,CustomerModel customer){
    Color color = Colors.white;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(
        title: Text(
            customer.name.toString(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold
          ),
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
        trailing: customer.id == 1 ? SizedBox() : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: (){},
                icon: Icon(Icons.edit,color: color,)
            ),
            IconButton(
                onPressed: (){
                  Get.defaultDialog(
                      title: "Delete!",
                      middleText: "Are you sure to delete!",
                      actions: [
                        TextButton(onPressed: (){
                          Get.back();
                        }, child: Text("Cancel"),),
                        TextButton(
                          onPressed: (){
                            customerController.delete(customer.id!);
                            Get.back();
                          },
                          child: Text("Ok"),
                        ),
                      ]
                  );
                },
                icon: Icon(Icons.delete,color: color,)
            ),
          ],
        ),
      ),
    );
  }
}
