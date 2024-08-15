import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:jue_pos/core/database/db_helper.dart';
import 'package:jue_pos/user/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    DbHelper dbObj = DbHelper();
    dbObj.copyDatabase();
    return GetMaterialApp(
      title: 'JuePos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        primaryColor: Colors.blueAccent,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
