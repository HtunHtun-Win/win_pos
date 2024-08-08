import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jue_pos/core/widgets/cust_drawer.dart';
import 'package:jue_pos/user/controllers/user_controller.dart';
import 'package:jue_pos/user/models/user.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text("Sale"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: CustDrawer(user: User.fromMap(controller.current_user.toJson())),
    );
  }
}
