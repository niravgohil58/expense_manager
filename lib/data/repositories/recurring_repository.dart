import 'package:uuid/uuid.dart';

import '../../core/database/database_helper.dart';
import '../models/recurring_template_model.dart';

class RecurringRepository {
  RecurringRepository({DatabaseHelper? dbHelper, Uuid? uuid})
      : _db = dbHelper ?? DatabaseHelper.instance,
        _uuid = uuid ?? const Uuid();

  final DatabaseHelper _db;
  final Uuid _uuid;

  static const String _table = 'recurring_templates';

  Future<List<RecurringTemplate>> getAll() async {
    final maps = await _db.queryAll(_table);
    final list = maps.map(RecurringTemplate.fromMap).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> insert(RecurringTemplate t) async {
    await _db.insert(_table, t.toMap());
  }

  Future<void> delete(String id) async {
    await _db.delete(_table, id);
  }

  Future<RecurringTemplate> createTemplate({
    required bool kindExpense,
    required double amount,
    required String categoryRef,
    required String accountId,
    String? note,
    required String frequency,
  }) async {
    final t = RecurringTemplate(
      id: _uuid.v4(),
      kindExpense: kindExpense,
      amount: amount,
      categoryRef: categoryRef,
      accountId: accountId,
      note: note,
      frequency: frequency,
      createdAt: DateTime.now(),
    );
    await insert(t);
    return t;
  }
}
