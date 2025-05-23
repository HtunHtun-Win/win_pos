import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/product/screens/product_adjust_screen.dart';
import 'package:win_pos/product/screens/product_list_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';

import '../../sales/screens/sales_voucher_screen.dart';

// ignore: must_be_immutable
class ProductScreen extends StatelessWidget {
  ProductScreen({super.key});
  UserController userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.off(() => SalesVoucherScreen());
        }
      },
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Inventory"),
              // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              bottom: const TabBar(
                labelStyle: TextStyle(color: Colors.white),
                unselectedLabelColor: Colors.white,
                tabs: [
                  Tab(
                    text: "List",
                  ),
                  Tab(
                    text: "Adjust",
                  ),
                ],
              ),
            ),
            drawer: CustDrawer(
                user: User.fromMap(userController.current_user.toJson())),
            body: TabBarView(
              children: [ProductListScreen(), ProductAdjustScreen()],
            ),
          )),
    );
  }
}
