import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/reports/purchase_reports/screens/purchase_report_screen.dart';
import 'package:win_pos/reports/sale_reports/screens/sales_report_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';

import 'inventory_reports/screens/inventory_report_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: CustDrawer(user: User.fromMap(controller.current_user.toJson())),
      body: ListView(
        children: [
          ListItem(context, const Icon(Icons.shopping_cart), "Sales", () {
            Get.to(() => const SalesReportScreen());
          }),
          ListItem(context, const Icon(Icons.add_shopping_cart), "Purchase", () {
            Get.to(() => const PurchaseReportScreen());
          }),
          ListItem(context, const Icon(Icons.inventory), "Inventory", () {
            Get.to(() => const InventoryReportScreen());
          }),
          ListItem(context, const Icon(Icons.attach_money), "Financial", () {
            // Get.to(() => CategoryScreen());
          }),
        ],
      ),
    );
  }

  Widget ListItem(context, icon, text, VoidCallback fun) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2,horizontal: 8),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(1),
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
