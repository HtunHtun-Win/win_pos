import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:jue_pos/core/widgets/cust_drawer.dart';
import 'package:jue_pos/product/screens/product_list_screen.dart';
import 'package:jue_pos/user/controllers/user_controller.dart';
import 'package:jue_pos/user/models/user.dart';

class ProductScreen extends StatelessWidget {
  ProductScreen({super.key});
  UserController userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Inventory"),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            bottom: TabBar(
              tabs: [
                Tab(text: "List",),
                Tab(text: "Adjust",),
                Tab(text: "Lost/Damage",),
              ],
            ),
          ),
          drawer: CustDrawer(user: User.fromMap(userController.current_user.toJson())),
          body: TabBarView(
            children: [
              ProductListScreen(),
              Container(),
              Container()
            ],
          ),
        )
    );
  }
}
