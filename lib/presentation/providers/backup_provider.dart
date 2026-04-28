import 'package:flutter/foundation.dart';

import '../../data/backup/backup_service.dart';
import '../../core/database/database_helper.dart';

/// Wraps [BackupService] for UI loading state.
class BackupProvider extends ChangeNotifier {
  BackupProvider({DatabaseHelper? databaseHelper})
      : _service = BackupService(databaseHelper ?? DatabaseHelper.instance);

  final BackupService _service;

  bool _busy = false;
  bool get isBusy => _busy;

  /// Saves backup JSON under app documents; returns absolute file path.
  Future<String> exportToDocumentsFile() async {
    _busy = true;
    notifyListeners();
    try {
      return await _service.exportToDocumentsFile();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> importFromJsonString(String jsonString) async {
    _busy = true;
    notifyListeners();
    try {
      await _service.importFromJsonString(jsonString);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
