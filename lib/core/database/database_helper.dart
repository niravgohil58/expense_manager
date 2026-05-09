import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database helper for SQLite operations
/// Manages all database tables: accounts, expenses, transfers, udhar
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Closes the cached connection and clears it; optionally deletes the DB file (tests).
  @visibleForTesting
  static Future<void> resetForTesting({bool deleteFile = false}) async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    if (deleteFile) {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'expense_app.db');
      await deleteDatabase(path);
    }
  }

  /// Deletes local SQLite file after closing the handle (different Firebase account).
  Future<void> wipeLocalDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_app.db');
    await deleteDatabase(path);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 4,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Runs [action] in a single SQLite transaction.
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action,
  ) async {
    final db = await database;
    return db.transaction(action);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Incomes table
      await db.execute('''
        CREATE TABLE incomes (
          id TEXT PRIMARY KEY,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          accountId TEXT NOT NULL,
          date TEXT NOT NULL,
          note TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (accountId) REFERENCES accounts (id)
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // Categories table
      await db.execute('''
        CREATE TABLE categories (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          iconCode INTEGER NOT NULL,
          colorValue INTEGER NOT NULL,
          isEnabled INTEGER NOT NULL DEFAULT 1,
          isSystem INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL
        )
      ''');

      // Insert default categories
      final now = DateTime.now().toIso8601String();
      final defaultCategories = [
        {'id': 'food', 'name': 'Food', 'iconCode': 0xe532, 'colorValue': 0xFFE57373, 'isSystem': 1}, // Icons.restaurant
        {'id': 'travel', 'name': 'Travel', 'iconCode': 0xe1d5, 'colorValue': 0xFF64B5F6, 'isSystem': 1}, // Icons.directions_car
        {'id': 'rent', 'name': 'Rent', 'iconCode': 0xe318, 'colorValue': 0xFF81C784, 'isSystem': 1}, // Icons.home
        {'id': 'shopping', 'name': 'Shopping', 'iconCode': 0xe59c, 'colorValue': 0xFFBA68C8, 'isSystem': 1}, // Icons.shopping_bag
        {'id': 'other', 'name': 'Other', 'iconCode': 0xe402, 'colorValue': 0xFF90A4AE, 'isSystem': 1}, // Icons.more_horiz
      ];

      for (final cat in defaultCategories) {
        await db.insert('categories', {
          ...cat,
          'isEnabled': 1,
          'createdAt': now,
        });
      }
    }

    if (oldVersion < 4) {
      await db.execute('ALTER TABLE expenses ADD COLUMN attachmentPath TEXT');
      await db.execute('''
        CREATE TABLE category_budgets (
          categoryId TEXT NOT NULL,
          year INTEGER NOT NULL,
          month INTEGER NOT NULL,
          limitAmount REAL NOT NULL,
          PRIMARY KEY (categoryId, year, month),
          FOREIGN KEY (categoryId) REFERENCES categories (id)
        )
      ''');
      await db.execute('''
        CREATE TABLE recurring_templates (
          id TEXT PRIMARY KEY,
          kind TEXT NOT NULL,
          amount REAL NOT NULL,
          categoryRef TEXT NOT NULL,
          accountId TEXT NOT NULL,
          note TEXT,
          frequency TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (accountId) REFERENCES accounts (id)
        )
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Accounts table
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        iconCode INTEGER NOT NULL,
        colorValue INTEGER NOT NULL,
        isEnabled INTEGER NOT NULL DEFAULT 1,
        isSystem INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
    
    // Insert default categories
    final now = DateTime.now().toIso8601String();
    final defaultCategories = [
      {'id': 'food', 'name': 'Food', 'iconCode': 0xe532, 'colorValue': 0xFFE57373, 'isSystem': 1},
      {'id': 'travel', 'name': 'Travel', 'iconCode': 0xe1d5, 'colorValue': 0xFF64B5F6, 'isSystem': 1},
      {'id': 'rent', 'name': 'Rent', 'iconCode': 0xe318, 'colorValue': 0xFF81C784, 'isSystem': 1},
      {'id': 'shopping', 'name': 'Shopping', 'iconCode': 0xe59c, 'colorValue': 0xFFBA68C8, 'isSystem': 1},
      {'id': 'other', 'name': 'Other', 'iconCode': 0xe402, 'colorValue': 0xFF90A4AE, 'isSystem': 1},
    ];

    for (final cat in defaultCategories) {
      await db.insert('categories', {
        ...cat,
        'isEnabled': 1,
        'createdAt': now,
      });
    }

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        category TEXT NOT NULL, -- This will now store categoryId
        accountId TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        createdAt TEXT NOT NULL,
        attachmentPath TEXT,
        FOREIGN KEY (accountId) REFERENCES accounts (id),
        FOREIGN KEY (category) REFERENCES categories (id)
      )
    ''');

    // Transfers table
    await db.execute('''
      CREATE TABLE transfers (
        id TEXT PRIMARY KEY,
        fromAccountId TEXT NOT NULL,
        toAccountId TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (fromAccountId) REFERENCES accounts (id),
        FOREIGN KEY (toAccountId) REFERENCES accounts (id)
      )
    ''');

    // Udhar table
    await db.execute('''
      CREATE TABLE udhar (
        id TEXT PRIMARY KEY,
        personName TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        paidAmount REAL NOT NULL DEFAULT 0,
        accountId TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        date TEXT NOT NULL,
        note TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (accountId) REFERENCES accounts (id)
      )
    ''');

    // Udhar Settlements table
    await db.execute('''
      CREATE TABLE udhar_settlements (
        id TEXT PRIMARY KEY,
        udharId TEXT NOT NULL,
        amount REAL NOT NULL,
        accountId TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (udharId) REFERENCES udhar (id),
        FOREIGN KEY (accountId) REFERENCES accounts (id)
      )
    ''');

    // Incomes table
    await db.execute('''
      CREATE TABLE incomes (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        accountId TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (accountId) REFERENCES accounts (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE category_budgets (
        categoryId TEXT NOT NULL,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        limitAmount REAL NOT NULL,
        PRIMARY KEY (categoryId, year, month),
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE recurring_templates (
        id TEXT PRIMARY KEY,
        kind TEXT NOT NULL,
        amount REAL NOT NULL,
        categoryRef TEXT NOT NULL,
        accountId TEXT NOT NULL,
        note TEXT,
        frequency TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (accountId) REFERENCES accounts (id)
      )
    ''');

    // Insert default accounts
    await db.insert('accounts', {
      'id': 'cash',
      'name': 'Cash',
      'type': 'cash',
      'balance': 0.0,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  // Generic CRUD operations

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<Map<String, dynamic>?> queryById(String table, String id) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String id,
  ) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String table, String id) async {
    final db = await database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    final db = await database;
    await db.update(
      'accounts',
      {
        'balance': newBalance,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  Future<List<Map<String, dynamic>>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    return await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUdharSettlements(String udharId) async {
    final db = await database;
    return await db.query(
      'udhar_settlements',
      where: 'udharId = ?',
      whereArgs: [udharId],
      orderBy: 'date DESC',
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
