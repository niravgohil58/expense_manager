import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/database/database_helper.dart';
import 'backup_schema.dart';

/// Thrown when backup JSON is invalid or incompatible.
class BackupFormatException implements Exception {
  BackupFormatException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Export/import full local DB as JSON (replace-all import).
///
/// Export writes only with [dart:io] + `path_provider` (no share/JNI plugins)
/// so it works on devices where `libdartjni.so` fails for FFI-based sharing.
class BackupService {
  BackupService(this._dbHelper);

  final DatabaseHelper _dbHelper;

  static const List<String> _tablesOrderedForInsert = [
    'accounts',
    'categories',
    'category_budgets',
    'recurring_templates',
    'expenses',
    'transfers',
    'incomes',
    'udhar',
    'udhar_settlements',
  ];

  /// FK-safe delete order (children before parents).
  static const List<String> _tablesOrderedForDelete = [
    'udhar_settlements',
    'udhar',
    'transfers',
    'expenses',
    'incomes',
    'category_budgets',
    'recurring_templates',
    'categories',
    'accounts',
  ];

  /// Builds backup map from database rows (table → list of column maps).
  Future<Map<String, dynamic>> buildBackupPayload() async {
    final db = await _dbHelper.database;
    final map = <String, dynamic>{
      'schemaVersion': kBackupSchemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'app': kBackupAppId,
    };

    for (final table in _tablesOrderedForInsert) {
      final rows = await db.query(table);
      map[table] = rows;
    }

    return map;
  }

  String encodePrettyJson(Map<String, dynamic> payload) {
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Writes JSON under app documents and returns the absolute path.
  ///
  /// Does not use sharing plugins (avoids JNI `libdartjni.so` issues on some
  /// Android builds). User can copy the path, upload via Files/Drive, etc.
  Future<String> exportToDocumentsFile() async {
    final payload = await buildBackupPayload();
    final jsonStr = encodePrettyJson(payload);
    final docsDir = await getApplicationDocumentsDirectory();
    final safeStamp =
        DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    final fileName = 'expense_manager_backup_$safeStamp.json';
    final path = p.join(docsDir.path, fileName);
    await File(path).writeAsString(jsonStr);
    return path;
  }

  int _schemaVersionFromJson(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    throw BackupFormatException('Missing or invalid schemaVersion.');
  }

  /// Parses and validates JSON string from a backup file.
  Map<String, dynamic> parseAndValidate(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! Map) {
      throw BackupFormatException('Backup root must be a JSON object.');
    }
    final decodedMap = Map<String, dynamic>.from(decoded);

    final app = decodedMap['app'];
    if (app != kBackupAppId) {
      throw BackupFormatException(
        'Unknown backup source (expected app: $kBackupAppId).',
      );
    }

    final version = _schemaVersionFromJson(decodedMap['schemaVersion']);
    if (version < 1 || version > kBackupSchemaVersion) {
      throw BackupFormatException(
        'Unsupported schemaVersion: $version (max $kBackupSchemaVersion).',
      );
    }

    for (final table in _tablesOrderedForInsert) {
      final v = decodedMap[table];
      if (v != null && v is! List) {
        throw BackupFormatException('Invalid table payload: $table');
      }
    }

    final accounts = decodedMap['accounts'];
    if (accounts is! List || accounts.isEmpty) {
      throw BackupFormatException('Backup must include at least one account.');
    }

    return decodedMap;
  }

  /// Clears all user tables and inserts rows from [payload]. Runs in one transaction.
  Future<void> importReplaceAll(Map<String, dynamic> payload) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      for (final table in _tablesOrderedForDelete) {
        await txn.delete(table);
      }

      for (final table in _tablesOrderedForInsert) {
        final raw = payload[table];
        if (raw == null) continue;
        final list = raw as List<dynamic>;
        for (final row in list) {
          if (row is! Map) {
            throw BackupFormatException('Invalid row in $table');
          }
          final map = Map<String, dynamic>.from(row);
          await txn.insert(table, map);
        }
      }
    });
  }

  /// Convenience: validate JSON string then import.
  Future<void> importFromJsonString(String jsonString) async {
    final payload = parseAndValidate(jsonString);
    await importReplaceAll(payload);
  }
}
