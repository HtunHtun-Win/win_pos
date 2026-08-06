import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/category/screens/category_screen.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/expense/screen/expense_category_edit_screen.dart';
import 'package:win_pos/setting/controller/printer_controller.dart';
import 'package:win_pos/setting/data_management_screen.dart';
import 'package:win_pos/setting/printer_select_screen.dart';
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
    PrinterController printerController = Get.find<PrinterController>();
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.off(() => SalesVoucherScreen());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        drawer:
            CustDrawer(user: User.fromMap(controller.current_user.toJson())),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          children: [
            _sectionLabel('Shop & Hardware', theme),
            const SizedBox(height: 10),
            _settingTile(
              context,
              icon: Icons.storefront,
              label: 'Shop Info',
              description: 'Update store details and branding',
              onTap: () => Get.to(() => ShopInfoScreen()),
            ),
            _settingTile(
              context,
              icon: Icons.print,
              label: 'Printer',
              description: 'Select receipt printer and settings',
              onTap: () => Get.to(() => const PrinterSelectScreen()),
            ),
            const SizedBox(height: 20),
            _sectionLabel('Business Settings', theme),
            const SizedBox(height: 10),
            _settingTile(
              context,
              icon: Icons.people,
              label: 'Users',
              description: 'Manage staff and access roles',
              onTap: () => Get.to(() => UserScreen()),
            ),
            _settingTile(
              context,
              icon: Icons.category,
              label: 'Category',
              description: 'Manage product categories',
              onTap: () => Get.to(() => CategoryScreen()),
            ),
            _settingTile(
              context,
              icon: Icons.money,
              label: 'Rename Expense Name',
              description: 'Configure expense categories',
              onTap: () => Get.to(() => ExpenseCategoryEditScreen()),
            ),
            _settingTile(
              context,
              icon: Icons.payment,
              label: 'Payment Method',
              description: 'Configure payment options',
              onTap: () => Get.to(() => PaymentScreen()),
            ),
            const SizedBox(height: 20),
            _sectionLabel('Data', theme),
            const SizedBox(height: 10),
            _settingTile(
              context,
              icon: Icons.backup,
              label: 'Data Management',
              description: 'Backup and restore your database',
              onTap: () => Get.to(() => const DataManagementScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.85),
      ),
    );
  }

  Widget _settingTile(BuildContext context,
      {required IconData icon,
      required String label,
      required String description,
      required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        title: Text(
          label,
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
          ),
        ),
        trailing: Icon(Icons.chevron_right,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        onTap: onTap,
      ),
    );
  }
}
