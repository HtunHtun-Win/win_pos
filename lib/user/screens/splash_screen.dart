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
    Future.delayed(const Duration(seconds: 1), () {
      _checkAuth();
    });
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 700),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/images/shop_logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  'LightPOS',
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 28),
                ),
              ),
              const SizedBox(height: 8),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Simple • Fast • Reliable',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 26),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
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
