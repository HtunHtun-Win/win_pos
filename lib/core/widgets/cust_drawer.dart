import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jue_pos/sales/screens/sales_screen.dart';
import 'package:jue_pos/setting/setting_screen.dart';
import 'package:jue_pos/user/screens/login_screen.dart';
import '../../user/models/user.dart';

class CustDrawer extends StatelessWidget {
  User user;
  CustDrawer({required this.user});

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
              child: Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Image.asset("assets/images/shop_logo.png"),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "JuePos",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          user.name.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    )
                  ],
                )
              )
          ),
          Expanded(
              child: ListView(
                children: [
                  ListItem(context,Icon(Icons.shopping_cart),"Sales",(){Get.off(SalesScreen());}),
                  ListItem(context,Icon(Icons.add_shopping_cart),"Purchase",(){}),
                  ListItem(context,Icon(Icons.inventory),"Inventory",(){}),
                  ListItem(context,Icon(Icons.people),"Contact",(){}),
                  ListItem(context,Icon(Icons.monetization_on),"Income Expense",(){}),
                  ListItem(context,Icon(Icons.menu_book),"Report",(){}),
                  ListItem(context,Icon(Icons.settings),"Setting",(){Get.off(SettingScreen());}),
                  ListItem(context,Icon(Icons.exit_to_app),"Logout",(){Get.offAll(LoginScreen());}),
                ],
              )
          ),
        ],
      ),
    );
  }

  Widget ListItem(context,Icon icon,String title,VoidCallback fun){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: icon,
        iconColor: Theme.of(context).primaryColor,
        title: Text(title),
        onTap: fun,
      ),
    );
  }
}
