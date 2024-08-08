import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jue_pos/core/widgets/cust_drawer.dart';
import 'package:jue_pos/user/controllers/user_controller.dart';

import '../models/user.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text("User List"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: CustDrawer(),
    );
  }
}
