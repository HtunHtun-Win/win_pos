import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import '../controller/sales_controller.dart';

class SalesSaveScreen extends StatelessWidget {
  SalesSaveScreen({super.key});
  SalesController salesController = Get.find();

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text("Save Vouchers"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: (){
                Get.back();
              },
              icon: Icon(Icons.save)
          )
        ],
      ),
    );
  }
}
