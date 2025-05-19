import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    return Drawer(
      // backgroundColor: Colors.deepPurple,
      child: Column(
        children: [
          DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Image.asset("assets/images/shop_logo.png"),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "LightPos",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user.name.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ))),
          Expanded(
              child: ListView(
            children: [
              if(user.role_id!=3)
              ListItem(context, const Icon(Icons.shopping_cart), "Sales", () {
                Get.off(() => SalesVoucherScreen());
              }),
              if(user.role_id!=2)
              ListItem(context, const Icon(Icons.add_shopping_cart), "Purchase",
                  () {
                    Get.off(() => PurchaseVoucherScreen());
                  }),
              if(user.role_id==1)
              ListItem(context, const Icon(Icons.inventory), "Inventory", () {
                Get.off(() => ProductScreen());
              }),
              ListItem(context, const Icon(Icons.people), "Contact", () {
                Get.off(() => const ContactScreen());
              }),
              ListItem(
                  context, const Icon(Icons.monetization_on), "Income Expense",
                  () {
                Get.off(() => ExpenseScreen());
              }),
              ListItem(context, const Icon(Icons.menu_book), "Report", () {
                Get.off(() => const ReportsScreen());
              }),
              if(user.role_id==1)
              ListItem(context, const Icon(Icons.settings), "Setting", () {
                Get.off(() => const SettingScreen());
              }),
              ListItem(context, const Icon(Icons.exit_to_app), "Logout", () async{
                final SharedPreferences pref = await SharedPreferences.getInstance();
                pref.setBool("remember_me", false);
                Get.offAll(() => const LoginScreen());
              }),
            ],
          )),
        ],
      ),
    );
  }

  Widget ListItem(context, Icon icon, String title, VoidCallback fun) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: icon,
        iconColor: Theme.of(context).primaryColor,
        title: Text(title),
        onTap: fun,
      ),
    );
  }
}
