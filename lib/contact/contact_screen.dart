import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:jue_pos/contact/customer/screens/customer_screen.dart';
import 'package:jue_pos/core/widgets/cust_drawer.dart';

import '../user/controllers/user_controller.dart';
import '../user/models/user.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen();

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Contacts'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            bottom: TabBar(
              tabs: [
                Tab(text: "Customers"),
                Tab(text: "Suppliers",),
              ],
            ),
          ),
          drawer: CustDrawer(user: User.fromMap(controller.current_user.toJson())),
          body: TabBarView(
            children: [
              CustomerScreen(),
              Container(),
            ],
          ),
        ),
    );
  }
}
