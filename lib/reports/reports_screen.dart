import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/ai/screens/ai_chat_screen.dart';
import 'package:win_pos/ai/screens/ai_report_screen.dart';
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
          // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        drawer: CustDrawer(user: user),
        body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reports Hub',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quickly access sales, purchase, inventory and financial reports in one place.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (user.role_id != 3)
              buildReportCard(
                context,
                icon: Icons.shopping_cart,
                title: 'Sales Reports',
                subtitle: 'View sales analytics and trends',
                onTap: () => Get.to(() => SalesReportScreen()),
              ),
            if (user.role_id != 2)
              buildReportCard(
                context,
                icon: Icons.add_shopping_cart,
                title: 'Purchase Reports',
                subtitle: 'Track purchase orders and costs',
                onTap: () => Get.to(() => PurchaseReportScreen()),
              ),
            buildReportCard(
              context,
              icon: Icons.inventory,
              title: 'Inventory Reports',
              subtitle: 'Monitor stock movements and valuation',
              onTap: () => Get.to(() => const InventoryReportScreen()),
            ),
            if (user.role_id == 1)
              buildReportCard(
                context,
                icon: Icons.attach_money,
                title: 'Financial Reports',
                subtitle: 'Review income, expenses and cash flow',
                onTap: () => Get.to(() => FinancialReportScreen()),
              ),
          ],
        ),
      ),
    ));
  }

  Widget buildReportCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: theme.cardColor,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 28, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: theme.iconTheme.color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
