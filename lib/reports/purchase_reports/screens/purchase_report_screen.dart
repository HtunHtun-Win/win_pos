import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/reports/purchase_reports/screens/monthly_purchase_report_screen.dart';
import 'package:win_pos/reports/purchase_reports/screens/yearly_purchase_report_screen.dart';
import 'package:win_pos/shop/shop_info_controller.dart';
import 'purchase_product_screen.dart';
import 'purchase_report_voucher_screen.dart';

class PurchaseReportScreen extends StatelessWidget {
  PurchaseReportScreen({super.key});
  ShopInfoController shopInfoController = Get.put(ShopInfoController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          children: [
            _buildHeader(theme),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildMenuCard(
                    context,
                    icon: Icons.shopping_cart,
                    title: 'Purchase Vouchers',
                    subtitle: 'View purchase invoices and totals',
                    onTap: () => Get.to(() => PurchaseReportVoucherScreen()),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.inventory_2,
                    title: 'Purchase Items',
                    subtitle: 'Review purchased items and quantities',
                    onTap: () => Get.to(() => PurchaseProductScreen()),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Monthly Purchase Report',
                    subtitle: 'See Purchase report by monthly',
                    onTap: () => Get.to(() => const MonthlyPurchaseReportScreen()),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Yearly Purchase Report',
                    subtitle: 'See Purchase report by yearly',
                    onTap: () => Get.to(() => const YearlyPurchaseReportScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(24),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.shopping_bag, color: theme.colorScheme.onPrimary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Purchase Reports',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Browse purchase vouchers and item summaries with quick filters.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withAlpha(220),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
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
