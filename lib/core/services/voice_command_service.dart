import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum VoiceTransactionType { expense, income }

class ParsedTransaction {
  final VoiceTransactionType type;
  final double? amount;
  final String? categoryName;
  final String? accountName;
  final String? note;

  const ParsedTransaction({
    required this.type,
    this.amount,
    this.categoryName,
    this.accountName,
    this.note,
  });

  @override
  String toString() {
    return 'ParsedTransaction(type: $type, amount: $amount, category: $categoryName, account: $accountName, note: $note)';
  }
}

/// Service to handle speech-to-text integration and natural language parsing.
class VoiceCommandService {
  VoiceCommandService._();

  static final VoiceCommandService instance = VoiceCommandService._();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  /// Initialize speech-to-text engine.
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onError: (val) => debugPrint('SpeechToText Error: $val'),
        onStatus: (val) => debugPrint('SpeechToText Status: $val'),
      );
    } catch (e) {
      debugPrint('SpeechToText Initialization Failed: $e');
      _isInitialized = false;
    }
    return _isInitialized;
  }

  /// Check if the engine is currently listening.
  bool get isListening => _speech.isListening;

  /// Start listening and stream results.
  Future<void> startListening({
    required Function(String text) onResult,
    required Function(double soundLevel) onSoundLevelChange,
    Function(String status)? onStatus,
    String? localeId,
  }) async {
    final initialized = await initialize();
    if (!initialized) return;

    if (onStatus != null) {
      _speech.statusListener = onStatus;
    }

    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      onSoundLevelChange: onSoundLevelChange,
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        localeId: localeId,
      ),
    );
  }

  /// Stop listening explicitly.
  Future<void> stopListening() async {
    if (_isInitialized) {
      await _speech.stop();
    }
  }

  /// Parse natural language voice inputs into transaction details.
  ParsedTransaction parseCommand(String text, List<String> categories, {List<String>? accounts}) {
    final cleanText = text.toLowerCase().trim();

    // 1. Identify Type (English-only)
    VoiceTransactionType type = VoiceTransactionType.expense;
    final incomeKeywords = ['salary', 'got', 'received', 'recieved', 'earned', 'income', 'bonus', 'refund', 'earn', 'inward'];
    final expenseKeywords = ['spent', 'paid', 'expense', 'bought', 'cost', 'purchase', 'outward'];

    int incomeScore = 0;
    int expenseScore = 0;
    for (final kw in incomeKeywords) {
      if (cleanText.contains(kw)) incomeScore++;
    }
    for (final kw in expenseKeywords) {
      if (cleanText.contains(kw)) expenseScore++;
    }
    if (incomeScore > expenseScore) {
      type = VoiceTransactionType.income;
    }

    // 2. Extract Amount
    double? amount;
    final sanitizedText = cleanText.replaceAll(',', '');
    final amountRegex = RegExp(r'\b\d+(?:\.\d{1,2})?\b');
    final matches = amountRegex.allMatches(sanitizedText);
    if (matches.isNotEmpty) {
      amount = double.tryParse(matches.first.group(0) ?? '');
    }

    // 3. Extract Category
    String? matchedCategory;
    final sortedCategories = List<String>.from(categories)..sort((a, b) => b.length.compareTo(a.length));
    for (final catName in sortedCategories) {
      if (cleanText.contains(catName.toLowerCase())) {
        matchedCategory = catName;
        break;
      }
    }

    // 4. Extract Account
    String? matchedAccount;
    if (accounts != null) {
      final sortedAccounts = List<String>.from(accounts)..sort((a, b) => b.length.compareTo(a.length));
      for (final accName in sortedAccounts) {
        if (cleanText.contains(accName.toLowerCase())) {
          matchedAccount = accName;
          break;
        }
      }
    }

    // 5. Extract Note (clean up amounts, categories, and accounts)
    String note = text;
    final forMatch = RegExp(r'\bfor\s+(.+)$', caseSensitive: false).firstMatch(text);
    if (forMatch != null) {
      note = forMatch.group(1)?.trim() ?? text;
    } else {
      String tempNote = text;
      if (matchedCategory != null) {
        tempNote = tempNote.replaceAll(RegExp(matchedCategory, caseSensitive: false), '');
      }
      if (matchedAccount != null) {
        tempNote = tempNote.replaceAll(RegExp(matchedAccount, caseSensitive: false), '');
      }
      if (amount != null) {
        tempNote = tempNote.replaceAll(amount.toString(), '');
        tempNote = tempNote.replaceAll(amount.toInt().toString(), '');
      }

      final stopWords = [
        r'\bspent\b', r'\bgot\b', r'\breceived\b', r'\brecieved\b', r'\bearned\b',
        r'\bsalary\b', r'\bpaid\b', r'\bexpense\b', r'\bbought\b', r'\bon\b',
        r'\bin\b', r'\ba\b', r'\bthe\b', r'\brupees\b', r'\brupee\b', r'\brs\b',
        r'\binr\b', r'\bof\b', r'\bfor\b', r'\bfrom\b', r'\bto\b', r'\binto\b', r'\busing\b', r'\bby\b'
      ];
      for (final pattern in stopWords) {
        tempNote = tempNote.replaceAll(
          RegExp(pattern, caseSensitive: false),
          '',
        );
      }

      tempNote = tempNote.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (tempNote.isNotEmpty) {
        note = tempNote;
      } else {
        note = '';
      }
    }

    // Capitalize note first letter
    if (note.isNotEmpty) {
      note = note[0].toUpperCase() + note.substring(1);
    }

    return ParsedTransaction(
      type: type,
      amount: amount,
      categoryName: matchedCategory,
      accountName: matchedAccount,
      note: note.isNotEmpty ? note : null,
    );
  }
}
