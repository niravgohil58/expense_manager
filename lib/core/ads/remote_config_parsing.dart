import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Firebase Console entries typed as **Text** (or JSON imports) often arrive as strings.
/// [FirebaseRemoteConfig.getBool] / [getInt] alone can mis-read those values.
bool rcReadBool(FirebaseRemoteConfig rc, String key, bool fallback) {
  final raw = rc.getString(key).trim().toLowerCase();
  if (raw.isNotEmpty) {
    if (raw == 'true' || raw == '1' || raw == 'yes') return true;
    if (raw == 'false' || raw == '0' || raw == 'no') return false;
  }

  try {
    return rc.getBool(key);
  } catch (_) {
    return fallback;
  }
}

int rcReadInt(FirebaseRemoteConfig rc, String key, int fallback) {
  final raw = rc.getString(key).trim();
  if (raw.isNotEmpty) {
    final parsed = int.tryParse(raw);
    if (parsed != null) return parsed;
  }

  try {
    return rc.getInt(key);
  } catch (_) {
    return fallback;
  }
}
