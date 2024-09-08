import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/screens/user_screen.dart';
import '../models/user.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController loginIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  UserController controller = Get.find();
  int currentOpt = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = controller.edit_user.value.name!;
    loginIdController.text = controller.edit_user.value.login_id!;
    passwordController.text = controller.edit_user.value.password!;
    currentOpt = controller.edit_user.value.role_id!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit User"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            userInput(
                context, "Name", const Icon(Icons.person), nameController),
            const SizedBox(
              height: 5,
            ),
            userInput(context, "Login Id", const Icon(Icons.fingerprint),
                loginIdController),
            const SizedBox(
              height: 5,
            ),
            userInput(context, "Password", const Icon(Icons.lock),
                passwordController, type: TextInputType.number),
            const SizedBox(
              height: 5,
            ),
            //for role selecter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text("Admin"),
                    Radio(
                        value: 1,
                        groupValue: currentOpt,
                        onChanged: (value) {
                          setState(() {
                            currentOpt = 1;
                          });
                        })
                  ],
                ),
                Row(
                  children: [
                    const Text("Sale"),
                    Radio(
                        value: 2,
                        groupValue: currentOpt,
                        onChanged: (value) {
                          setState(() {
                            currentOpt = 2;
                          });
                        })
                  ],
                ),
                Row(
                  children: [
                    const Text("Purchase"),
                    Radio(
                        value: 3,
                        groupValue: currentOpt,
                        onChanged: (value) {
                          setState(() {
                            currentOpt = 3;
                          });
                        })
                  ],
                ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                onPressed: () {
                  nameController.clear();
                  loginIdController.clear();
                  passwordController.clear();
                },
                child: const Text(
                  "Clear",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              TextButton(
                onPressed: () async {
                  var num = await controller.updateUser(
                      controller.edit_user.value.id!,
                      nameController.text,
                      loginIdController.text,
                      passwordController.text,
                      currentOpt);
                  if (num == -1) {
                    Get.snackbar("Duplicate!", "LoginId is already exists!");
                  } else if (num != 0) {
                    Get.back();
                  } else {
                    Get.snackbar(
                        "Invalid Input!", "Every input must have at least 2");
                  }
                },
                child: const Text(
                  "Update",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }

  Widget userInput(
      context, String hintText, Icon icon, TextEditingController tController,{type}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: tController,
        keyboardType: type,
        decoration: InputDecoration(
            border: const OutlineInputBorder(), hintText: hintText, icon: icon),
      ),
    );
  }
}
