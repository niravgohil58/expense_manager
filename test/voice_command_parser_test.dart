import 'package:flutter_test/flutter_test.dart';
import 'package:expense_app/core/services/voice_command_service.dart';

void main() {
  group('VoiceCommandService Parser Tests', () {
    final service = VoiceCommandService.instance;
    final categories = ['Food', 'Travel', 'Shopping', 'Rent', 'Other'];
    final accounts = ['Cash', 'HDFC Bank', 'SBI', 'Bank'];

    test('should parse simple English expense command', () {
      final res = service.parseCommand(
        'Spent 500 on Food for lunch',
        categories,
      );
      expect(res.type, VoiceTransactionType.expense);
      expect(res.amount, 500.0);
      expect(res.categoryName, 'Food');
      expect(res.note, 'Lunch');
    });

    test('should parse English income command', () {
      final res = service.parseCommand('Received salary of 50000', categories);
      expect(res.type, VoiceTransactionType.income);
      expect(res.amount, 50000.0);
      expect(res.note, isNull);
    });

    test('should parse mixed Hinglish expense command using English keywords', () {
      final res = service.parseCommand('200 travel par spent kiya', categories);
      expect(res.type, VoiceTransactionType.expense);
      expect(res.amount, 200.0);
      expect(res.categoryName, 'Travel');
    });

    test('should parse mixed Hinglish income command using English keywords', () {
      final res = service.parseCommand('50000 salary mili', categories);
      expect(res.type, VoiceTransactionType.income);
      expect(res.amount, 50000.0);
    });

    test('should handle decimal values and commas', () {
      final res = service.parseCommand(
        'spent 1,250.50 on Shopping for shoes',
        categories,
      );
      expect(res.type, VoiceTransactionType.expense);
      expect(res.amount, 1250.50);
      expect(res.categoryName, 'Shopping');
      expect(res.note, 'Shoes');
    });

    test('should parse English command and extract account name', () {
      final res = service.parseCommand(
        'spent 300 on Food using HDFC Bank for dinner',
        categories,
        accounts: accounts,
      );
      expect(res.type, VoiceTransactionType.expense);
      expect(res.amount, 300.0);
      expect(res.categoryName, 'Food');
      expect(res.accountName, 'HDFC Bank');
      expect(res.note, 'Dinner');
    });

    test('should parse English income command and extract account name', () {
      final res = service.parseCommand(
        'Received salary of 50000 into SBI',
        categories,
        accounts: accounts,
      );
      expect(res.type, VoiceTransactionType.income);
      expect(res.amount, 50000.0);
      expect(res.accountName, 'SBI');
      expect(res.note, isNull);
    });

    test('should parse expense using Cash account', () {
      final res = service.parseCommand(
        'Spent 150 on Travel from Cash for fuel',
        categories,
        accounts: accounts,
      );
      expect(res.type, VoiceTransactionType.expense);
      expect(res.amount, 150.0);
      expect(res.categoryName, 'Travel');
      expect(res.accountName, 'Cash');
      expect(res.note, 'Fuel');
    });
  });
}
