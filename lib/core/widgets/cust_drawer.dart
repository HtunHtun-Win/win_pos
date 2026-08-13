import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_pos/ai/screens/ai_chat_screen.dart';
import 'package:win_pos/ai/screens/ai_report_screen.dart';
import 'package:win_pos/contact/contact_screen.dart';
import 'package:win_pos/expense/screen/expense_screen.dart';
import 'package:win_pos/product/screens/product_screen.dart';
import 'package:win_pos/purchase/screens/purchase_voucher_screen.dart';
import 'package:win_pos/reports/reports_screen.dart';
import 'package:win_pos/sales/screens/sales_voucher_screen.dart';
import 'package:win_pos/setting/setting_screen.dart';
import 'package:win_pos/user/screens/login_screen.dart';
import '../../user/models/user.dart';

class CustDrawer extends StatelessWidget {
  final User user;
  const CustDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Modern header card with avatar and quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primaryContainer
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: theme.colorScheme.onPrimary,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/shop_logo.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LightPOS',
                                style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(user.name ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary)),
                            const SizedBox(height: 8),
                            Row(children: [
                              Chip(
                                backgroundColor: theme
                                    .colorScheme.primaryContainer
                                    .withValues(alpha: 0.2),
                                label: Text(_roleLabel(user.role_id),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.secondary)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Container()),
                            ])
                          ],
                        ),
                      ),
                      // Quick actions
                      Column(
                        children: [
                          _HeaderAction(
                              icon: Icons.add_shopping_cart,
                              label: 'Buy',
                              onTap: () {
                                Navigator.of(context).pop();
                                if (user.role_id != 2) {
                                  Get.to(() => PurchaseVoucherScreen());
                                }
                              }),
                          const SizedBox(height: 8),
                          _HeaderAction(
                              icon: Icons.shopping_cart,
                              label: 'Sale',
                              onTap: () {
                                Navigator.of(context).pop();
                                if (user.role_id != 3) {
                                  Get.to(() => SalesVoucherScreen());
                                }
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Primary section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Primary', style: theme.textTheme.labelLarge),
                  ),
                  ..._menuItems(context).map((it) => _DrawerTile(item: it)),
                  const SizedBox(height: 8),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Admin', style: theme.textTheme.labelLarge),
                  ),
                  if (user.role_id == 1)
                    _DrawerTile(
                        item: _DrawerItem('Setting', Icons.settings,
                            () => Get.off(() => const SettingScreen()))),
                  _LogoutTile(onLogout: () async {
                    final confirmed = await Get.dialog<bool>(AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                            onPressed: () => Get.back(result: false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Get.back(result: true),
                            child: const Text('Logout',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ));
                    if (confirmed ?? false) {
                      final SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      await pref.setBool('remember_me', false);
                      Get.offAll(() => const LoginScreen());
                    }
                  }),
                  const SizedBox(height: 20),
                  Center(
                      child: Text('v${_appVersion()}',
                          style: theme.textTheme.bodySmall)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<_DrawerItem> _menuItems(BuildContext context) {
    final List<_DrawerItem> items = [];
    if (user.role_id != 3) {
      items.add(_DrawerItem('Sales', Icons.shopping_cart,
          () => Get.off(() => SalesVoucherScreen())));
    }
    if (user.role_id != 2) {
      items.add(_DrawerItem('Purchase', Icons.add_shopping_cart,
          () => Get.off(() => PurchaseVoucherScreen())));
    }
    if (user.role_id == 1) {
      items.add(_DrawerItem(
          'Inventory', Icons.inventory, () => Get.off(() => ProductScreen())));
    }
    items.add(_DrawerItem(
        'Contact', Icons.people, () => Get.off(() => const ContactScreen())));
    items.add(_DrawerItem('Income Expense', Icons.monetization_on,
        () => Get.off(() => ExpenseScreen())));
    items.add(_DrawerItem(
        'Report', Icons.menu_book, () => Get.off(() => const ReportsScreen())));
    items.add(_DrawerItem('AI Analysis', Icons.auto_awesome, () => Get.off(() => const AiReportScreen())));
    items.add(_DrawerItem('AI Chat', Icons.message, () => Get.off(() => const AiChatScreen())));
    return items;
  }
}

class _DrawerItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  _DrawerItem(this.title, this.icon, this.onTap);
}

class _DrawerTile extends StatelessWidget {
  final _DrawerItem item;
  const _DrawerTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        item.onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(item.icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(item.title, style: theme.textTheme.bodyLarge)),
            Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final Future<void> Function() onLogout;
  const _LogoutTile({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onLogout,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.exit_to_app, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text('Logout',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _HeaderAction({
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.onPrimary),
            const SizedBox(height: 4),
            Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onPrimary)),
          ],
        ),
      ),
    );
  }
}

String _roleLabel(int? roleId) {
  switch (roleId) {
    case 1:
      return 'Admin';
    case 2:
      return 'Purchase';
    case 3:
      return 'Sales';
    default:
      return 'User';
  }
}

String _appVersion() {
  return '3.1.0';
}
