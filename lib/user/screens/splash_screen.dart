import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_pos/purchase/screens/purchase_voucher_screen.dart';
import 'package:win_pos/sales/screens/sales_voucher_screen.dart';
import 'package:win_pos/user/controllers/user_controller.dart';
import 'package:win_pos/user/screens/login_screen.dart';

// ignore: must_be_immutable
class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  UserController controller = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      _checkAuth();
    });
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
          Center(
            child: ZoomIn(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    "LightPOS",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _checkAuth() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var isLogin = await pref.getBool("remember_me");
    if (isLogin ?? false) {
      var userString = await pref.getString("user");
      var user = jsonDecode(userString!);
      controller.setCurrentUser(user);
      if (user['role_id'] == 3) {
        Get.off(() => PurchaseVoucherScreen());
      } else {
        Get.off(() => SalesVoucherScreen());
      }
    } else {
      Get.off(() => const LoginScreen());
    }
  }
}
