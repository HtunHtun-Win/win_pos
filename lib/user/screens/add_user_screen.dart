import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/screens/user_screen.dart';

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
        title: Text("Add New User"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        child: Column(
          children: [
            userInput(context,"Name",Icon(Icons.person),nameController),
            SizedBox(height: 5,),
            userInput(context,"Login Id",Icon(Icons.fingerprint),loginIdController),
            SizedBox(height: 5,),
            userInput(context,"Password",Icon(Icons.lock),passwordController),
            SizedBox(height: 5,),
            //for role selecter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text("Admin"),
                    Radio(value: 1, groupValue: currentOpt, onChanged: (value){
                      setState(() {
                        currentOpt = 1;
                      });
                    })
                  ],
                ),
                Row(
                  children: [
                    const Text("Sale"),
                    Radio(value: 2, groupValue: currentOpt, onChanged: (value){
                      setState(() {
                        currentOpt = 2;
                      });
                    })
                  ],
                ),
                Row(
                  children: [
                    const Text("Purchase"),
                    Radio(value: 3, groupValue: currentOpt, onChanged: (value){
                      setState(() {
                        currentOpt = 3;
                      });
                    })
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: (){
                    nameController.clear();
                    loginIdController.clear();
                    passwordController.clear();
                  },
                  child: Text(
                      "Clear",
                    style: TextStyle(
                      fontSize: 18
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async{
                    var num = await controller.insertUser(
                        nameController.text,
                        loginIdController.text,
                        passwordController.text,
                        currentOpt
                    );
                    if(num==-1){
                      Get.snackbar(
                          "Duplicate!",
                          "LoginId is already exists!"
                      );
                    }else if(num!=0){
                      Get.off(()=>UserScreen());
                    }else{
                      Get.snackbar(
                        "Invalid Input!",
                        "Every input must have at least 2"
                      );
                    }
                  },
                  child: Text(
                      "Add",
                    style: TextStyle(
                        fontSize: 18
                    ),
                  ),
                ),
              ]
            )
          ],
        ),
      ),
    );
  }

  Widget userInput(context,String hint_text,Icon icon,TextEditingController t_controller){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: t_controller,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: hint_text,
            icon: icon
        ),
      ),
    );
  }
}
