import 'package:uuid/uuid.dart';
import '../../core/database/database_helper.dart';
import '../models/udhar_model.dart';
import '../models/udhar_settlement_model.dart';

/// Repository for Udhar and UdharSettlement database operations
class UdharRepository {
  final DatabaseHelper _dbHelper;
  final Uuid _uuid;

  UdharRepository({DatabaseHelper? dbHelper, Uuid? uuid})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _uuid = uuid ?? const Uuid();

  static const String _udharTable = 'udhar';
  static const String _settlementTable = 'udhar_settlements';

  // ============ UDHAR OPERATIONS ============

  /// Add new udhar
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
    await _dbHelper.insert(_udharTable, udhar.toMap());
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

  /// Delete udhar
  Future<void> deleteUdhar(String id) async {
    // Delete all settlements first
    final settlements = await getSettlementsForUdhar(id);
    for (final settlement in settlements) {
      await _dbHelper.delete(_settlementTable, settlement.id);
    }
    // Then delete the udhar
    await _dbHelper.delete(_udharTable, id);
  }

  // ============ SETTLEMENT OPERATIONS ============

  /// Add settlement to udhar
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
    await _dbHelper.insert(_settlementTable, settlement.toMap());

    // Update udhar paid amount and status
    final udhar = await getUdharById(udharId);
    if (udhar != null) {
      final newPaidAmount = udhar.paidAmount + amount;
      final newStatus = newPaidAmount >= udhar.amount
          ? UdharStatus.completed
          : UdharStatus.partial;
      
      await updateUdhar(udhar.copyWith(
        paidAmount: newPaidAmount,
        status: newStatus,
      ));
    }

    return settlement;
  }

  /// Get all settlements for an udhar
  Future<List<UdharSettlement>> getSettlementsForUdhar(String udharId) async {
    final maps = await _dbHelper.getUdharSettlements(udharId);
    return maps.map((map) => UdharSettlement.fromMap(map)).toList();
  }

  /// Delete settlement
  Future<void> deleteSettlement(String id) async {
    await _dbHelper.delete(_settlementTable, id);
  }
}
