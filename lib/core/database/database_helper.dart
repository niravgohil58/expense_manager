import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database helper for SQLite operations
/// Manages all database tables: accounts, expenses, transfers, udhar
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
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

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
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

    // Insert default accounts
    final now = DateTime.now().toIso8601String();
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
