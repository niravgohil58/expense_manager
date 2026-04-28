import 'package:flutter/foundation.dart';
import '../../core/errors/app_exceptions.dart';
import '../../data/models/udhar_model.dart';
import '../../data/models/udhar_settlement_model.dart';
import '../../data/repositories/udhar_repository.dart';
import 'account_provider.dart';

/// Provider for managing udhar (debt) state
class UdharProvider extends ChangeNotifier {
  final UdharRepository _repository;
  final AccountProvider _accountProvider;

  UdharProvider({
    UdharRepository? repository,
    required AccountProvider accountProvider,
  })  : _repository = repository ?? UdharRepository(),
        _accountProvider = accountProvider;

  List<Udhar> _udharList = [];
  final Map<String, List<UdharSettlement>> _settlements = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Udhar> get udharList => _udharList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get all 'dena' type udhar (money given - receivable)
  List<Udhar> get udharDena =>
      _udharList.where((u) => u.type == UdharType.dena).toList();

  /// Get all 'lena' type udhar (money taken - payable)
  List<Udhar> get udharLena =>
      _udharList.where((u) => u.type == UdharType.lena).toList();

  /// Get pending udhar only
  List<Udhar> get pendingUdhar =>
      _udharList.where((u) => u.status != UdharStatus.completed).toList();

  /// Total pending amount for 'dena' (Aapko Milna Hai)
  double get totalPendingDena {
    double total = 0.0;
    for (final udhar in udharDena) {
      total += udhar.pendingAmount;
    }
    return total;
  }

  /// Total pending amount for 'lena' (Aapko Dena Hai)
  double get totalPendingLena {
    double total = 0.0;
    for (final udhar in udharLena) {
      total += udhar.pendingAmount;
    }
    return total;
  }

  /// Get settlements for an udhar
  List<UdharSettlement> getSettlements(String udharId) =>
      _settlements[udharId] ?? [];

  /// Load all udhar records.
  ///
  /// When [showLoading] is false, [isLoading] is not toggled (e.g. background
  /// refresh or pull-to-refresh while keeping the list visible).
  Future<void> loadUdhar({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      _udharList = await _repository.getAllUdhar();
    } catch (e) {
      _error = 'Failed to load udhar: $e';
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// Load settlements for an udhar
  Future<void> loadSettlements(String udharId) async {
    try {
      final settlements = await _repository.getSettlementsForUdhar(udharId);
      _settlements[udharId] = settlements;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load settlements: $e';
      notifyListeners();
    }
  }

  /// Add new udhar (balance adjusted in repository transaction).
  Future<bool> addUdhar({
    required String personName,
    required UdharType type,
    required double amount,
    required String accountId,
    required DateTime date,
    String? note,
  }) async {
    try {
      await _repository.addUdhar(
        personName: personName,
        type: type,
        amount: amount,
        accountId: accountId,
        date: date,
        note: note,
      );

      await loadUdhar(showLoading: false);
      await _accountProvider.loadAccounts(showLoading: false);
      return true;
    } on InsufficientBalanceException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to add udhar: $e';
      notifyListeners();
      return false;
    }
  }

  /// Add settlement (balance adjusted in repository transaction).
  Future<bool> addSettlement({
    required String udharId,
    required double amount,
    required String accountId,
    required DateTime date,
    String? note,
  }) async {
    try {
      final udhar = _udharList.firstWhere((u) => u.id == udharId);

      if (amount > udhar.pendingAmount) {
        _error = 'Settlement amount cannot exceed pending amount';
        notifyListeners();
        return false;
      }

      await _repository.addSettlement(
        udharId: udharId,
        amount: amount,
        accountId: accountId,
        date: date,
        note: note,
      );

      await loadUdhar(showLoading: false);
      await loadSettlements(udharId);
      await _accountProvider.loadAccounts(showLoading: false);
      return true;
    } on InsufficientBalanceException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to add settlement: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete udhar (ledger reversal in repository).
  Future<bool> deleteUdhar(String id) async {
    try {
      await _repository.deleteUdhar(id);
      await loadUdhar(showLoading: false);
      await _accountProvider.loadAccounts(showLoading: false);
      return true;
    } on InsufficientBalanceException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete udhar: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get udhar by id
  Udhar? getUdharById(String id) {
    try {
      return _udharList.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
