import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/screens/login_screen.dart';

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
  bool isCurrentUser = false;
  int currentOpt = 1;

  @override
  void initState() {
    super.initState();
    nameController.text = controller.edit_user.value.name!;
    loginIdController.text = controller.edit_user.value.login_id!;
    passwordController.text = controller.edit_user.value.password!;
    currentOpt = controller.edit_user.value.role_id!;
    isCurrentUser =
        controller.current_user['id'] == controller.edit_user.value.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit User"),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            userInput(context, "Login Id", const Icon(Icons.badge),
                loginIdController),
            const SizedBox(
              height: 5,
            ),
            userInput(
                context, "Password", const Icon(Icons.lock), passwordController,
                type: TextInputType.number,
                filer: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ]),
            const SizedBox(
              height: 5,
            ),
            //for role selecter
            RadioGroup<int>(
              groupValue: currentOpt,
              onChanged: (int? value) {
                setState(() {
                  currentOpt = value!;
                });
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [Text("Admin"), Radio(value: 1)],
                  ),
                  Row(
                    children: [Text("Sale"), Radio(value: 2)],
                  ),
                  Row(
                    children: [Text("Purchase"), Radio(value: 3)],
                  ),
                ],
              ),
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
                      loginIdController.text.trim(),
                      passwordController.text,
                      currentOpt);
                  if (num == -1) {
                    Get.dialog(AlertDialog(
                      title: const Text("Duplicate!"),
                      content: const Text("LoginId is already exists."),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text("OK"))
                      ],
                    ));
                  } else if (num != 0) {
                    
                    if (isCurrentUser) {
                      final SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      await pref.setBool('remember_me', false);
                      Get.offAll(() => const LoginScreen());
                    }else{
                      Get.back();
                    }
                  } else {
                    Get.dialog(AlertDialog(
                      title: const Text("Invalid Input!"),
                      content: const Text(
                          "Every input must have at least 2 characters."),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text("OK"))
                      ],
                    ));
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
      context, String hintText, Icon icon, TextEditingController tController,
      {type, filer}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: tController,
        keyboardType: type,
        inputFormatters: filer,
        decoration: InputDecoration(
            border: const OutlineInputBorder(), hintText: hintText, icon: icon),
      ),
    );
  }
}
