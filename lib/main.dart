import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:win_pos/core/database/db_helper.dart';
import 'package:win_pos/setting/controller/printer_controller.dart';
import 'package:win_pos/user/screens/splash_screen.dart';
import 'package:get/get.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  Get.put(PrinterController(),permanent: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  //theme
  final theme = ThemeData(
    useMaterial3: true,
    // use bundled NotoSans fonts from pubspec
    fontFamily: 'NotoSans',

    // modern cohesive color system using a seed color
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),

    // subtle background
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),

    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF0F172A),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF06B6D4),
      foregroundColor: Colors.white,
      elevation: 6,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFFE6EEF6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 2,
        ),
      ),
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF475569),
      ),
    ),

    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  @override
  Widget build(BuildContext context) {
    DbHelper dbObj = DbHelper();
    dbObj.copyDatabase();
    return GetMaterialApp(
      title: 'LightPOS',
      debugShowCheckedModeBanner: false,
      theme: theme,
      // theme: ThemeData(
      //   appBarTheme: const AppBarTheme(
      //       titleTextStyle: TextStyle(fontSize: 20, color: Colors.white),
      //       backgroundColor: Colors.blueAccent,
      //       iconTheme: IconThemeData(
      //         color: Colors.white,
      //       )),
      //   floatingActionButtonTheme: const FloatingActionButtonThemeData(
      //     backgroundColor: Colors.blueAccent,
      //     foregroundColor: Colors.white,
      //   ),
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      //   primaryColor: Colors.blueAccent,
      //   useMaterial3: true,
      // ),
      home: SplashScreen(),
    );
  }
}
