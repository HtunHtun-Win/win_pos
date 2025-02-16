import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:win_pos/core/database/db_helper.dart';
import 'package:win_pos/user/screens/login_screen.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    DbHelper dbObj = DbHelper();
    dbObj.copyDatabase();
    return GetMaterialApp(
      title: 'WinPos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(fontSize: 20, color: Colors.white),
            backgroundColor: Colors.blueAccent,
            iconTheme: IconThemeData(
              color: Colors.white,
            )),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        primaryColor: Colors.blueAccent,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
