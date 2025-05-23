import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/category/screens/category_screen.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/setting/data_management_screen.dart';
import 'package:win_pos/shop/shop_info_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';
import 'package:win_pos/user/screens/user_screen.dart';

import '../payment/screens/payment_screen.dart';
import '../sales/screens/sales_voucher_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.off(() => SalesVoucherScreen());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Setting"),
          // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        drawer: CustDrawer(user: User.fromMap(controller.current_user.toJson())),
        body: ListView(
          children: [
            ListItem(context, const Icon(Icons.house), "Shop", () {
              Get.to(() => ShopInfoScreen());
            }),
            ListItem(context, const Icon(Icons.people), "Users", () {
              Get.to(() => UserScreen());
            }),
            ListItem(context, const Icon(Icons.category), "Category", () {
              Get.to(() => CategoryScreen());
            }),
            ListItem(context, const Icon(Icons.payment), "Payment Method", () {
              Get.to(() => PaymentScreen());
            }),
            ListItem(context, const Icon(Icons.backup), "Data Management", () {
              Get.to(() => const DataManagementScreen());
            }),
          ],
        ),
      ),
    );
  }

  Widget ListItem(context, icon, text, VoidCallback fun) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2,horizontal: 8),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 1),
          borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: icon,
        iconColor: Colors.white,
        title: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        onTap: fun,
      ),
    );
  }
}
