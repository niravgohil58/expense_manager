import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:expense_app/core/database/database_helper.dart';
import 'package:expense_app/data/backup/backup_service.dart';

void main() {
  final svc = BackupService(DatabaseHelper.instance);

  group('BackupService.parseAndValidate', () {
    test('rejects unknown app id', () {
      expect(
        () => svc.parseAndValidate(
          jsonEncode({
            'schemaVersion': 1,
            'app': 'other_app',
            'exportedAt': 'x',
            'accounts': [
              {
                'id': 'a',
                'name': 'Cash',
                'type': 'cash',
                'balance': 0,
                'createdAt': 't',
                'updatedAt': 't',
              },
            ],
          }),
        ),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('accepts minimal valid payload', () {
      final json = jsonEncode({
        'schemaVersion': 1,
        'app': 'expense_app',
        'exportedAt': '2020-01-01T00:00:00.000Z',
        'accounts': [
          {
            'id': 'a',
            'name': 'Cash',
            'type': 'cash',
            'balance': 0,
            'createdAt': 't',
            'updatedAt': 't',
          },
        ],
        'categories': <Map<String, dynamic>>[],
        'expenses': <Map<String, dynamic>>[],
        'transfers': <Map<String, dynamic>>[],
        'incomes': <Map<String, dynamic>>[],
        'udhar': <Map<String, dynamic>>[],
        'udhar_settlements': <Map<String, dynamic>>[],
      });

      expect(() => svc.parseAndValidate(json), returnsNormally);
    });

    test('rejects empty accounts', () {
      final json = jsonEncode({
        'schemaVersion': 1,
        'app': 'expense_app',
        'exportedAt': 'x',
        'accounts': [],
      });

      expect(
        () => svc.parseAndValidate(json),
        throwsA(isA<BackupFormatException>()),
      );
    });
  });
}
