import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/sales/screens/sales_voucher_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.put(UserController());
    TextEditingController useridController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    //pre setup userid and password
    useridController.text = "admin";
    passwordController.text = "admin";
    return Scaffold(
      body: Stack(
        children: [
          //for background color
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Colors.blue,
                  Colors.blueAccent,
                  Colors.blueAccent,
                  Colors.blue,
                ],
                    stops: [
                  0.1,
                  0.3,
                  0.7,
                  0.9
                ])),
          ),
          //for alignment
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 100, horizontal: 50),
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Image.asset("assets/images/shop_logo.png"),
                  ),
                  const Text(
                    "WinPos",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  userInput("LoginId", const Icon(Icons.fingerprint),
                      TextInputType.text, useridController), //input for userid
                  const SizedBox(
                    height: 5,
                  ),
                  userInput("Password", const Icon(Icons.lock),
                      TextInputType.number, passwordController,
                      obtext: true), //input for password
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          var loginId = useridController.text;
                          var password = passwordController.text;
                          var user =
                              await controller.validUser(loginId, password);
                          if (user.isNotEmpty) {
                            Get.off(() => SalesVoucherScreen());
                          } else {
                            Get.snackbar(
                              "Invalid Credentials",
                              "Wrong UserId or Password!",
                              colorText: Colors.white,
                              backgroundColor: Colors.black.withOpacity(.3),
                            );
                          }
                        },
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget userInput(String hintText, Icon icon, TextInputType type,
      TextEditingController tController,
      {bool? obtext}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(5, 5),
              blurRadius: 20)
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: tController,
        keyboardType: type,
        obscureText: obtext ?? false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white),
            iconColor: Colors.white,
            icon: icon),
      ),
    );
  }
}
