import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:win_pos/contact/customer/screens/customer_screen.dart';
import 'package:win_pos/contact/supplier/screens/supplier_screen.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/purchase/screens/purchase_voucher_screen.dart';

import '../sales/screens/sales_voucher_screen.dart';
import '../user/controllers/user_controller.dart';
import '../user/models/user.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    final user = User.fromMap(controller.current_user.toJson());
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if(user.role_id==3){
            Get.off(() => PurchaseVoucherScreen());
          }else{
            Get.off(() => SalesVoucherScreen());
          }
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Contacts'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            bottom: const TabBar(
              tabs: [
                Tab(text: "Customers"),
                Tab(
                  text: "Suppliers",
                ),
              ],
            ),
          ),
          drawer:
              CustDrawer(user: user),
          body: TabBarView(
            children: [
              CustomerScreen(),
              SupplierScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
