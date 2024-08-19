import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/sales/controller/sales_controller.dart';
import 'package:win_pos/sales/screens/sales_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';

class SalesVoucherScreen extends StatelessWidget {
  SalesVoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text("Sales Vouchers"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: CustDrawer(user: User.fromMap(controller.current_user.toJson())),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Get.to(()=>SalesScreen());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
