import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/category/screens/category_screen.dart';
import 'package:win_pos/core/widgets/cust_drawer.dart';
import 'package:win_pos/shop/shop_info_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/models/user.dart';
import 'package:win_pos/user/screens/user_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text("Setting"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: CustDrawer(user: User.fromMap(controller.current_user.toJson())),
      body: ListView(
        children: [
          ListItem(context,Icon(Icons.house),"Shop",(){Get.to(()=>ShopInfoScreen());}),
          ListItem(context,Icon(Icons.people),"Users",(){Get.to(()=>UserScreen());}),
          ListItem(context,Icon(Icons.category),"Category",(){Get.to(()=>CategoryScreen());}),
        ],
      ),
    );
  }

  Widget ListItem(context,icon,text,VoidCallback fun){
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(1),
        borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(
        leading: icon,
        iconColor: Colors.white,
        title: Text(
            text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18
          ),
        ),
        onTap: fun,
      ),
    );
  }
}
