import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jue_pos/user/screens/login_screen.dart';
import '../../user/models/user.dart';

class CustDrawer extends StatelessWidget {
  // User user;
  // CustDrawer({required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Container()),
          ListItem(Icon(Icons.shop_2),"Sales",(){}),
          ListTile(
            title: Text("Logout"),
            onTap: ()=>Get.off(()=>LoginScreen())
          )
        ],
      ),
    );
  }

  Widget ListItem(Icon icon,String title,var fun){
    return ListTile(
      leading: icon,
      title: Text(title),
    );
  }
}
