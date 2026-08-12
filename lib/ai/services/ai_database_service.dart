import 'dart:convert';
import 'package:win_pos/core/database/db_helper.dart';

class AiDatabaseService {
  
  DbHelper dbObj = DbHelper();

  /// Reads all user tables and their rows.
  Future<String> getAllDatabaseData() async {
    final db = await dbObj.database;

    final tables = await db.rawQuery('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
      AND name NOT LIKE 'sqlite_%'
      ORDER BY name
    ''');

    final Map<String, dynamic> result = {};

    for (final table in tables) {
      final tableName = table['name']?.toString();
      if (tableName == null || tableName.isEmpty) {
        continue;
      }

      try {
        final rows = await db.query(tableName);
        result[tableName] = rows;
      } catch (e) {
        result[tableName] = {
          '_error': 'Could not read table',
        };
      }
    }

    return const JsonEncoder.withIndent('  ').convert(result);
  }
}