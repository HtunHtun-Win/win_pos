import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:win_pos/sales/screens/sales_voucher_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserController controller = Get.put(UserController());
    TextEditingController userid_controller = TextEditingController();
    TextEditingController password_controller = TextEditingController();
    //pre setup userid and password
    userid_controller.text = "admin";
    password_controller.text = "admin";
    return Scaffold(
      body: Stack(
        children: [
          //for background color
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue,
                  Colors.blueAccent,
                  Colors.blueAccent,
                  Colors.blue,
                ],
                stops: [0.1,0.3,0.7,0.9]
              )
            ),
          ),
          //for alignment
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 100,horizontal: 50),
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Image.asset(
                        "assets/images/shop_logo.png"
                    ),
                  ),
                  Text(
                    "WinPos",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30
                    ),
                  ),
                  SizedBox(height: 5,),
                  userInput(
                      "LoginId",
                      Icon(Icons.fingerprint),
                      TextInputType.text,
                      userid_controller),//input for userid
                  SizedBox(height: 5,),
                  userInput(
                      "Password",
                      Icon(Icons.lock),
                      TextInputType.text,
                      password_controller,
                      obtext: true),//input for password
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: ()async{
                          var loginId = userid_controller.text;
                          var password = password_controller.text;
                          var user = await controller.validUser(loginId,password);
                          if(user.isNotEmpty){
                            Get.off(()=>SalesVoucherScreen());
                          }else{
                            Get.snackbar(
                                "Invalid Credentials",
                                "Wrong UserId or Password!",
                                colorText: Colors.white,
                                backgroundColor: Colors.black.withOpacity(.3),
                            );
                          }
                        },
                        child: Text(
                            "LOGIN",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        )
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget userInput(String hint_text,Icon icon,TextInputType type,TextEditingController t_controller,{bool? obtext}){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset:Offset(5,5),
              blurRadius: 20
          )
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: t_controller,
        keyboardType: type,
        obscureText: obtext??false,
        style: TextStyle(
          color: Colors.white
        ),
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint_text,
            hintStyle: TextStyle(
              color: Colors.white
            ),
            iconColor: Colors.white,
            icon: icon
        ),
      ),
    );
  }
}
