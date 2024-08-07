import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DbHelper {
  Database? _db;
  String DB_NAME = "juepos.db";

  Future<void> copyDatabase() async {
    // Get the application documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);

    // Check if the database already exists
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      // If not, copy it from the assets
      ByteData data = await rootBundle.load(join('assets/db', DB_NAME));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write the bytes to a new file
      await File(path).writeAsBytes(bytes);
    }
  }

  Future<Database> get database async {
    _db = await onInit();
    return _db!;
  }

  Future<Database> onInit() async {
    Directory documentDir = await getApplicationDocumentsDirectory();
    var path = join(documentDir.path, DB_NAME);
    var db = await openDatabase(path, version: 1);
    return db;
  }
}
