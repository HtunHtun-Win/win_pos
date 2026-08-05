import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/reports/inventory_reports/screens/sale_log_screen.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Reports'),
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
                    icon: Icons.inventory,
                    title: 'Stock Balance',
                    subtitle: 'See current stock quantities and availability',
                    onTap: () => Get.to(() => StockBalanceScreen()),
                  ),
                  if (user.role_id == 1)
                    _buildMenuCard(
                      context,
                      icon: Icons.assessment,
                      title: 'Stock Valuation',
                      subtitle: 'Review stock value with cost and totals',
                      onTap: () => Get.to(() => StockBalanceValuationScreen()),
                    ),
                  _buildMenuCard(
                    context,
                    icon: Icons.history,
                    title: 'Sale Price History',
                    subtitle: 'Track product price changes over time',
                    onTap: () => Get.to(() => SaleLogScreen()),
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
            child: Icon(Icons.inventory_2, color: theme.colorScheme.onPrimary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventory Reports',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitor stock, valuation, and price history with a single tap.',
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
