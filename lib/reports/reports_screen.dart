import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/reports/purchase_reports/screens/purchase_report_screen.dart';
import 'package:win_pos/reports/sale_reports/screens/sales_report_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';

import '../purchase/screens/purchase_voucher_screen.dart';
import '../sales/screens/sales_voucher_screen.dart';
import 'financial_reports/screens/financial_report_screen.dart';
import 'inventory_reports/screens/inventory_report_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    var user = User.fromMap(controller.current_user.toJson());
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Reports"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        drawer: CustDrawer(user: user),
        body: ListView(
          children: [
            if(user.role_id!=3)
            ListItem(context, const Icon(Icons.shopping_cart), "Sales", () {
              Get.to(() => const SalesReportScreen());
            }),
            if(user.role_id!=2)
            ListItem(context, const Icon(Icons.add_shopping_cart), "Purchase", () {
              Get.to(() => const PurchaseReportScreen());
            }),
            ListItem(context, const Icon(Icons.inventory), "Inventory", () {
              Get.to(() => const InventoryReportScreen());
            }),
            if(user.role_id==1)
            ListItem(context, const Icon(Icons.attach_money), "Financial", () {
              Get.to(() => const FinancialReportScreen());
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
