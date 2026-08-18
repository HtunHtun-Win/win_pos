// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/reports/sale_reports/screens/monthly_sales_item_report_screen.dart';
import 'package:win_pos/reports/sale_reports/screens/monthly_sales_report_screen.dart';
import 'package:win_pos/reports/sale_reports/screens/most_sales_product_screen.dart';
import 'package:win_pos/reports/sale_reports/screens/sales_product_screen.dart';
import 'package:win_pos/reports/sale_reports/screens/sales_report_voucher_screen.dart';
import 'package:win_pos/reports/sale_reports/screens/vip_customer_report_screen.dart';
import 'package:win_pos/reports/sale_reports/screens/yearly_sales_report_screen.dart';
import 'package:win_pos/shop/shop_info_controller.dart';

class SalesReportScreen extends StatelessWidget {
  SalesReportScreen({super.key});
  ShopInfoController shopInfoController = Get.put(ShopInfoController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.onPrimary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.bar_chart,
                      size: 28,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Reports',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Browse vouchers, items, and top-selling products in a clean dashboard.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary
                                .withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  buildMenuCard(
                    context,
                    icon: Icons.shopping_cart,
                    title: 'Sales Vouchers',
                    subtitle: 'View invoice history and details',
                    onTap: () => Get.to(() => SalesReportVoucherScreen()),
                  ),
                  buildMenuCard(
                    context,
                    icon: Icons.inventory_2,
                    title: 'Sales Items',
                    subtitle: 'Review sold items and quantities',
                    onTap: () => Get.to(() => SalesProductScreen()),
                  ),
                  buildMenuCard(
                    context,
                    icon: Icons.star,
                    title: 'Best Selling Items',
                    subtitle: 'Discover your top-selling products',
                    onTap: () => Get.to(() => MostSalesProductScreen()),
                  ),
                  buildMenuCard(
                    context,
                    icon: Icons.people,
                    title: 'Vip Customer Report',
                    subtitle: 'Discover your vip customer',
                    onTap: () => Get.to(() => VipCustomerReportScreen()),
                  ),
                  buildMenuCard(
                    context,
                    icon: Icons.stacked_bar_chart_sharp,
                    title: 'Monthly Sales Items Report',
                    subtitle: 'See sales item report by monthly',
                    onTap: () => Get.to(() => const MonthlySalesItemReportScreen()),
                  ),
                  buildMenuCard(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Monthly Sales Report',
                    subtitle: 'See sales report by monthly',
                    onTap: () => Get.to(() => const MonthlySalesReportScreen()),
                  ),
                  buildMenuCard(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Yearly Sales Report',
                    subtitle: 'See sales report by yearly',
                    onTap: () => Get.to(() => const YearlySalesReportScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: theme.cardColor,
        elevation: 1,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
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
