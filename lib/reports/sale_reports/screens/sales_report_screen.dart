import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/reports/sale_reports/screens/sales_product_screen.dart';
import 'package:win_pos/reports/sale_reports/screens/sales_report_voucher_screen.dart';
import '../../../user/controllers/user_controller.dart';

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Reports"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          ListItem(context, const Icon(Icons.shopping_cart), "Sales Vouchers", () {
            Get.to(() => SalesReportVoucherScreen());
          }),
          ListItem(context, const Icon(Icons.inventory_2), "Sales Items", () {
            Get.to(() => SalesProductScreen());
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
