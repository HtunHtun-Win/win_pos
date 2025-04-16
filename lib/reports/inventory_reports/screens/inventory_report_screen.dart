import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/reports/inventory_reports/screens/stock_balance_screen.dart';
import 'package:win_pos/reports/inventory_reports/screens/stock_balance_valuation_screen.dart';

import '../../../user/controllers/user_controller.dart';
import '../../../user/models/user.dart';

class InventoryReportScreen extends StatelessWidget {
  const InventoryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    var user = User.fromMap(controller.current_user.toJson());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory Reports"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          ListItem(context, const Icon(Icons.inventory), "Stock Balance", () {
            Get.to(() => StockBalanceScreen());
          }),
          if(user.role_id==1)
          ListItem(context, const Icon(Icons.inventory), "Stock Balance With Valuation", () {
            Get.to(() => StockBalanceValuationScreen());
          }),
        ],
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
