import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:win_pos/user/controllers/user_controller.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController loginIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  UserController controller = Get.find();
  int currentOpt = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New User"),
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
            userInput(context, "Password", const Icon(Icons.lock),
                passwordController, type: TextInputType.number,filter: <TextInputFormatter>[
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Text("Admin"),
                        Radio<int>(value: 1)
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Text("Sale"),
                        Radio(value: 2)
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Text("Purchase"),
                        Radio(value: 3)
                      ],
                    ),
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
                  var num = await controller.insertUser(
                      nameController.text,
                      loginIdController.text.trim(),
                      passwordController.text,
                      currentOpt);
                  if (num == -1) {
                    Get.dialog(
                        AlertDialog(
                          title: const Text("Duplicate!"),
                          content: const Text("LoginId is already exists."),
                          actions: [
                            TextButton(onPressed: (){Get.back();}, child: const Text("OK"))
                          ],
                        )
                    );
                  } else if (num != 0) {
                    Get.back();
                  } else {
                    Get.dialog(
                        AlertDialog(
                          title: const Text("Invalid Input!"),
                          content: const Text("Every input must have at least 2 characters."),
                          actions: [
                            TextButton(onPressed: (){Get.back();}, child: const Text("OK"))
                          ],
                        )
                    );
                  }
                },
                child: const Text(
                  "Add",
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
      context, String hintText, Icon icon, TextEditingController tController,{type,filter}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: tController,
        keyboardType: type,
        inputFormatters: filter,
        decoration: InputDecoration(
            border: const OutlineInputBorder(), hintText: hintText, icon: icon),
      ),
    );
  }
}
