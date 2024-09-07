import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/sales/controller/sales_controller.dart';
import 'package:win_pos/sales/screens/sales_screen.dart';
import 'package:win_pos/sales/screens/voucher_item.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';

class SalesVoucherScreen extends StatelessWidget {
  SalesVoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    SalesController salesController = Get.put(SalesController());
    salesController.getCustomer();
    salesController.getAllVouchers();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Vouchers"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: CustDrawer(user: User.fromMap(controller.current_user.toJson())),
      body: Obx(() {
        return ListView.builder(
            itemCount: salesController.vouchers.length,
            itemBuilder: (context, index) {
              var voucher = salesController.vouchers[index];
              String cName =
                  salesController.customers[voucher.customer_id] ?? "no";
              return VoucherItem(voucher: voucher, cName: cName);
            });
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => SalesScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
