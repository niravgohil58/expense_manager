import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/database_helper.dart';
import '../models/udhar_model.dart';
import '../models/udhar_settlement_model.dart';
import 'account_repository.dart';

/// Repository for Udhar and UdharSettlement database operations
class UdharRepository {
  final DatabaseHelper _dbHelper;
  final Uuid _uuid;
  final AccountRepository _accountRepository;

  UdharRepository({
    DatabaseHelper? dbHelper,
    Uuid? uuid,
    AccountRepository? accountRepository,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _uuid = uuid ?? const Uuid(),
        _accountRepository =
            accountRepository ?? AccountRepository(dbHelper: dbHelper ?? DatabaseHelper.instance);

  static const String _udharTable = 'udhar';
  static const String _settlementTable = 'udhar_settlements';
  static const double _eps = 1e-9;

  // ============ UDHAR OPERATIONS ============

  /// Add new udhar and adjust account balance atomically.
  Future<Udhar> addUdhar({
    required String personName,
    required UdharType type,
    required double amount,
    required String accountId,
    required DateTime date,
    String? note,
  }) async {
    final now = DateTime.now();
    final udhar = Udhar(
      id: _uuid.v4(),
      personName: personName,
      type: type,
      amount: amount,
      paidAmount: 0,
      accountId: accountId,
      status: UdharStatus.pending,
      date: date,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
    await _dbHelper.transaction((txn) async {
      await txn.insert(_udharTable, udhar.toMap());
      if (type == UdharType.dena) {
        await _accountRepository.applyBalanceDeltaTxn(txn, accountId, -amount);
      } else {
        await _accountRepository.applyBalanceDeltaTxn(txn, accountId, amount);
      }
    });
    return udhar;
  }

  /// Get all udhar records
  Future<List<Udhar>> getAllUdhar() async {
    final maps = await _dbHelper.queryAll(_udharTable);
    return maps.map((map) => Udhar.fromMap(map)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get udhar by id
  Future<Udhar?> getUdharById(String id) async {
    final map = await _dbHelper.queryById(_udharTable, id);
    return map != null ? Udhar.fromMap(map) : null;
  }

  /// Get all udhar of type 'dena' (money given - receivable)
  Future<List<Udhar>> getUdharDena() async {
    final maps = await _dbHelper.queryWhere(
      _udharTable,
      'type = ?',
      [UdharType.dena.name],
    );
    return maps.map((map) => Udhar.fromMap(map)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get all udhar of type 'lena' (money taken - payable)
  Future<List<Udhar>> getUdharLena() async {
    final maps = await _dbHelper.queryWhere(
      _udharTable,
      'type = ?',
      [UdharType.lena.name],
    );
    return maps.map((map) => Udhar.fromMap(map)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get pending udhar records
  Future<List<Udhar>> getPendingUdhar() async {
    final maps = await _dbHelper.queryWhere(
      _udharTable,
      'status != ?',
      [UdharStatus.completed.name],
    );
    return maps.map((map) => Udhar.fromMap(map)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get total pending amount for 'dena' (Aapko Milna Hai)
  Future<double> getTotalPendingDena() async {
    final udharList = await getUdharDena();
    double total = 0.0;
    for (final udhar in udharList) {
      total += udhar.pendingAmount;
    }
    return total;
  }

  /// Get total pending amount for 'lena' (Aapko Dena Hai)
  Future<double> getTotalPendingLena() async {
    final udharList = await getUdharLena();
    double total = 0.0;
    for (final udhar in udharList) {
      total += udhar.pendingAmount;
    }
    return total;
  }

  /// Update udhar
  Future<void> updateUdhar(Udhar udhar) async {
    await _dbHelper.update(_udharTable, udhar.toMap(), udhar.id);
  }

  /// Delete udhar, reverse all ledger effects, remove settlements.
  Future<void> deleteUdhar(String id) async {
    final udhar = await getUdharById(id);
    if (udhar == null) return;
    final settlements = await getSettlementsForUdhar(id);

    await _dbHelper.transaction((txn) async {
      for (final s in settlements) {
        await _reverseSettlementBalance(txn, udhar.type, s);
        await txn.delete(_settlementTable, where: 'id = ?', whereArgs: [s.id]);
      }
      await _reversePrincipal(txn, udhar);
      await txn.delete(_udharTable, where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> _reverseSettlementBalance(
    Transaction txn,
    UdharType type,
    UdharSettlement s,
  ) async {
    if (type == UdharType.dena) {
      await _accountRepository.applyBalanceDeltaTxn(txn, s.accountId, -s.amount);
    } else {
      await _accountRepository.applyBalanceDeltaTxn(txn, s.accountId, s.amount);
    }
  }

  Future<void> _reversePrincipal(Transaction txn, Udhar udhar) async {
    if (udhar.type == UdharType.dena) {
      await _accountRepository.applyBalanceDeltaTxn(txn, udhar.accountId, udhar.amount);
    } else {
      await _accountRepository.applyBalanceDeltaTxn(txn, udhar.accountId, -udhar.amount);
    }
  }

  // ============ SETTLEMENT OPERATIONS ============

  /// Add settlement, update udhar, adjust balance atomically.
  Future<UdharSettlement> addSettlement({
    required String udharId,
    required double amount,
    required String accountId,
    required DateTime date,
    String? note,
  }) async {
    final settlement = UdharSettlement(
      id: _uuid.v4(),
      udharId: udharId,
      amount: amount,
      accountId: accountId,
      date: date,
      note: note,
      createdAt: DateTime.now(),
    );

    await _dbHelper.transaction((txn) async {
      final udharRows = await txn.query(_udharTable, where: 'id = ?', whereArgs: [udharId]);
      if (udharRows.isEmpty) {
        throw StateError('Udhar not found: $udharId');
      }
      final udhar = Udhar.fromMap(udharRows.first);
      final pending = udhar.amount - udhar.paidAmount;
      if (amount - pending > _eps) {
        throw StateError('Settlement exceeds pending amount');
      }

      await txn.insert(_settlementTable, settlement.toMap());

      final newPaidAmount = udhar.paidAmount + amount;
      final newStatus = newPaidAmount >= udhar.amount - _eps
          ? UdharStatus.completed
          : UdharStatus.partial;

      await txn.update(
        _udharTable,
        udhar
            .copyWith(
              paidAmount: newPaidAmount,
              status: newStatus,
              updatedAt: DateTime.now(),
            )
            .toMap(),
        where: 'id = ?',
        whereArgs: [udharId],
      );

      if (udhar.type == UdharType.dena) {
        await _accountRepository.applyBalanceDeltaTxn(txn, accountId, amount);
      } else {
        await _accountRepository.applyBalanceDeltaTxn(txn, accountId, -amount);
      }
    });

    return settlement;
  }

  /// Get all settlements for an udhar
  Future<List<UdharSettlement>> getSettlementsForUdhar(String udharId) async {
    final maps = await _dbHelper.getUdharSettlements(udharId);
    return maps.map((map) => UdharSettlement.fromMap(map)).toList();
  }

  /// Remove settlement and reverse its ledger and udhar paid amount.
  Future<void> deleteSettlement(String settlementId) async {
    await _dbHelper.transaction((txn) async {
      final rows = await txn.query(
        _settlementTable,
        where: 'id = ?',
        whereArgs: [settlementId],
      );
      if (rows.isEmpty) return;
      final settlement = UdharSettlement.fromMap(rows.first);

      final udharRows = await txn.query(_udharTable, where: 'id = ?', whereArgs: [settlement.udharId]);
      if (udharRows.isEmpty) {
        throw StateError('Udhar missing for settlement');
      }
      final udhar = Udhar.fromMap(udharRows.first);

      if (udhar.type == UdharType.dena) {
        await _accountRepository.applyBalanceDeltaTxn(txn, settlement.accountId, -settlement.amount);
      } else {
        await _accountRepository.applyBalanceDeltaTxn(txn, settlement.accountId, settlement.amount);
      }

      final rawPaid = udhar.paidAmount - settlement.amount;
      final newPaid = rawPaid.clamp(0.0, udhar.amount);
      final UdharStatus newStatus;
      if (newPaid <= _eps) {
        newStatus = UdharStatus.pending;
      } else if (newPaid >= udhar.amount - _eps) {
        newStatus = UdharStatus.completed;
      } else {
        newStatus = UdharStatus.partial;
      }

      await txn.update(
        _udharTable,
        udhar.copyWith(paidAmount: newPaid, status: newStatus, updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [udhar.id],
      );

      await txn.delete(_settlementTable, where: 'id = ?', whereArgs: [settlementId]);
    });
  }
}
