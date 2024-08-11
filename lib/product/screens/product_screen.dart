import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:jue_pos/core/widgets/cust_drawer.dart';
import 'package:jue_pos/user/controllers/user_controller.dart';
import 'package:jue_pos/user/models/user.dart';

class ProductScreen extends StatelessWidget {
  ProductScreen({super.key});
  UserController userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: CustDrawer(user: User.fromMap(userController.current_user.toJson())),
    );
  }
}
