import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jue_pos/core/widgets/cust_drawer.dart';
import 'package:jue_pos/user/controllers/user_controller.dart';
import 'package:jue_pos/user/screens/add_user_screen.dart';
import 'package:jue_pos/user/screens/edit_user_screen.dart';

import '../models/user.dart';

class UserScreen extends StatelessWidget {
  // const UserScreen({super.key});
  UserController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    controller.getAll();
    return Scaffold(
      appBar: AppBar(
        title: Text("User List"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: (){
                Get.to(()=>AddUserScreen());
              },
              icon: Icon(Icons.add)
          )
        ],
      ),
      drawer: CustDrawer(user: User.fromMap(controller.current_user.toJson()),),
      body: Obx(()=>ListView.builder(
        itemCount: controller.users.length,
        itemBuilder: (context,index){
          User user = controller.users[index];
          return ListItem(user);
        },
      )),
    );
  }

  Widget ListItem(User user){
    return Column(
      children: [
        ListTile(
          title: Row(
            children: [
              Column(
                children: [
                  Text(
                      user.login_id.toString(),
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  Text(
                      user.password.toString(),
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Column(
                children: [
                  Text(
                    user.name.toString(),
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    "(role)",
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ],
              )
            ],
          ),
          // subtitle: Text(user.password.toString()),
          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: (){
                controller.edit_user.value = user;
                Get.to(()=>EditUserScreen());
              }, icon: Icon(Icons.edit)),
              IconButton(
                  onPressed: (){
                    Get.defaultDialog(
                      title: "Delete!",
                      middleText: "Tap outside area to cancel!",
                      onConfirm: (){
                        controller.deleteUser(user.id!);
                        Get.back();
                      }
                    );
                  },
                  icon: Icon(Icons.delete)),
            ],
          ),
        ),
        Divider()
      ],
    );
  }
}
